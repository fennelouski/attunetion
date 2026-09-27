import test from 'node:test';
import assert from 'node:assert/strict';
process.env.OPENAI_API_KEY='unit-test-not-a-real-key';
process.env.RATE_LIMIT_ENABLED='false';
let providerCalls=0;
let providerMockOverride;
globalThis.fetch=async(...args)=> { providerCalls++;if(providerMockOverride)return providerMockOverride(...args);return Response.json({id:'test',object:'chat.completion',created:0,model:'test',choices:[{index:0,finish_reason:'stop',message:{role:'assistant',content:JSON.stringify({backgroundColor:'#112233',textColor:'#FFFFFF',accentColor:'#ABCDEF',name:'Quiet Focus',reasoning:'A calm palette.'})}}]}); };
const routes=new Map();
for(const name of ['generate-theme','generate-quote','rephrase-intention','generate-monthly-intention','generate-weekly-intentions']) {
  routes.set(name,(await import(`../dist/api/ai/${name}.js`)).default);
}
const request=(name,body,headers={})=>new Request(`https://test.invalid/api/ai/${name}`,{method:'POST',headers:{'Content-Type':'application/json',...headers},body:typeof body==='string'?body:JSON.stringify(body)});

test('all compiled ESM AI routes import without missing modules',()=>assert.equal(routes.size,5));
test('malformed JSON, null, arrays and oversized bodies fail before provider calls',async()=>{
 const count=providerCalls;
 for(const [name,route] of routes) for(const body of ['{','null','[]','{"text":"'+'x'.repeat(65536)+'"}']) {
  const response=await route.fetch(request(name,body));assert.ok([400,413].includes(response.status),`${name}: ${response.status}`);
 }
 assert.equal(providerCalls,count);
});
test('invalid AI payload fields cannot reach the paid provider',async()=>{
 const count=providerCalls;
 for(const [name,body] of [
  ['generate-theme',{intentionText:' '.repeat(5)}],['generate-theme',{intentionText:'x'.repeat(2001)}],
  ['generate-quote',{intentionText:42}],['rephrase-intention',{intentionText:'Be present',previousPhrases:[null]}],
  ['generate-monthly-intention',{previousIntentions:[null]}],['generate-monthly-intention',{previousIntentions:[{text:'hello',month:42}]}],
  ['generate-weekly-intentions',{userInfo:'Be present',weekStartDate:'not-a-date'}],
  ['generate-weekly-intentions',{userInfo:'Be present',weekStartDate:'2026-09-28',previousIntentions:[{text:'hi',date:'2026-09-28',scope:'invalid'}]}]
 ]) {assert.equal((await routes.get(name).fetch(request(name,body))).status,400);}
 assert.equal(providerCalls,count);
});
test('configured API key enforcement stays intact',async()=>{
 process.env.API_SECRET_KEY='test-secret';const count=providerCalls;
 assert.equal((await routes.get('generate-theme').fetch(request('generate-theme',{intentionText:'Be present'}))).status,401);
 assert.equal(providerCalls,count);delete process.env.API_SECRET_KEY;
});
test('valid theme request returns the native response shape using mocked provider',async()=>{
 const response=await routes.get('generate-theme').fetch(request('generate-theme',{intentionText:'Approach today with patient attention'}));
 assert.equal(response.status,200);assert.equal((await response.json()).theme.backgroundColor,'#112233');
});
test('enabled limiter rejects request51 in its two-hour instance window',async()=>{
 process.env.RATE_LIMIT_ENABLED='true';const {checkRateLimit}=await import('../dist/lib/rateLimit.js');
 for(let i=0;i<50;i++)assert.equal(checkRateLimit('test-limit').allowed,true);
 assert.equal(checkRateLimit('test-limit').allowed,false);process.env.RATE_LIMIT_ENABLED='false';
});

test('weekly generation returns nine intentions covering the requested week',async()=>{
 const original=providerMockOverride;
 const days=Array.from({length:7},(_,i)=>({date:new Date(Date.UTC(2026,8,28+i)).toISOString().slice(0,10),text:'Bring patient attention to everyday moments',scope:'day'}));
 const schedule={intentions:[...days,{date:'2026-09-28',text:'Approach the week with curiosity',scope:'week'},{date:'2026-10-01',text:'Make room for steady personal growth',scope:'month'}]};
 const reply=content=>Response.json({id:'test',object:'chat.completion',created:0,model:'test',choices:[{index:0,finish_reason:'stop',message:{role:'assistant',content:JSON.stringify(content)}}]});
 providerMockOverride=async()=>reply(schedule);
 try {
  const res=await routes.get('generate-weekly-intentions').fetch(request('generate-weekly-intentions',{userInfo:'Synthetic profile',weekStartDate:'2026-09-28'}));
  assert.equal(res.status,200);const data=await res.json();assert.equal(data.intentions.length,9);assert.equal(data.weekEndDate,'2026-10-04');
 } finally {providerMockOverride=original;}
});
test('malformed weekly provider data is rejected and asynchronous provider errors are sanitized',async()=>{
 const original=providerMockOverride;const originalError=console.error;const logged=[];console.error=(...args)=>logged.push(JSON.stringify(args));
 const submit=()=>routes.get('generate-weekly-intentions').fetch(request('generate-weekly-intentions',{userInfo:'Synthetic profile',weekStartDate:'2026-09-28'}));
 try {
  const days=Array.from({length:7},()=>({date:'2026-09-28',text:'A nonempty intention',scope:'day'}));
  const malformed={intentions:[...days,{date:'2026-09-28',text:'A weekly intention',scope:'week'},{date:'2026-10-01',text:'A monthly intention',scope:'month'}]};
  providerMockOverride=async()=>Response.json({id:'test',object:'chat.completion',choices:[{message:{content:JSON.stringify(malformed)}}]});
  assert.equal((await submit()).status,500);
  providerMockOverride=async()=>Response.json({error:{message:'private-provider-marker',type:'invalid_request_error'}},{status:400});
  const res=await submit();assert.equal(res.status,500);assert.doesNotMatch(await res.text(),/private-provider-marker/);assert.doesNotMatch(logged.join('\n'),/private-provider-marker/);
 } finally {providerMockOverride=original;console.error=originalError;}
});
