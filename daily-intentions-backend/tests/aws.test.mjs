import test from 'node:test';
import assert from 'node:assert/strict';
process.env.OPENAI_API_KEY='unit-test-not-a-real-key';
process.env.SOURCE_COMMIT='a'.repeat(40);
process.env.RATE_LIMIT_ENABLED='true';
let calls=0;
globalThis.fetch=async()=>{calls++;throw new Error('Unexpected provider call');};
const {handler}=await import('../dist/aws/handler.js');
const event=(path,method='GET',body=undefined,headers={})=>({rawPath:path,headers,requestContext:{domainName:'test.invalid',http:{method,sourceIp:'192.0.2.4'}},body});
const decode=r=>Buffer.from(r.body,'base64').toString('utf8');
test('Lambda adapter preserves health response, revision and static legal document',async()=>{
 const h=await handler(event('/api/health'));assert.equal(h.statusCode,200);assert.equal(JSON.parse(decode(h)).revision,'a'.repeat(40));
 const page=await handler(event('/legal/eula.html'));assert.equal(page.statusCode,200);assert.match(decode(page),/html/);
 const legal=await handler(event('/api/legal/privacy-policy'));assert.equal(legal.statusCode,302);assert.equal(legal.headers.location,'https://nathanfennel.com/attunetion/privacy.html');
});
test('Lambda rejects malformed AI requests and never serves files outside public',async()=>{
 assert.equal((await handler(event('/api/ai/generate-theme','POST','null'))).statusCode,400);
 assert.equal((await handler(event('/%2e%2e%2fpackage.json'))).statusCode,404);
 assert.equal((await handler(event('/api/intentions'))).statusCode,404);
 assert.equal(calls,0);
});
test('Lambda uses AWS source IP rather than caller supplied identity headers',async()=>{
 const {checkRateLimit}=await import('../dist/lib/rateLimit.js');
 for(let i=0;i<50;i++)checkRateLimit('ip:192.0.2.4');
 const res=await handler(event('/api/ai/generate-theme','POST',JSON.stringify({intentionText:'Be patient'}),{'X-Forwarded-For':'1.2.3.4','X-User-Id':'another-user'}));
 assert.equal(res.statusCode,429);assert.equal(calls,0);
});
