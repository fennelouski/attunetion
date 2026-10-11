import test from 'node:test';
import assert from 'node:assert/strict';
process.env.API_SECRET_KEY='synthetic-test-api-key';
process.env.UNSPLASH_ACCESS_KEY='synthetic-test-provider-key';
process.env.UNSPLASH_UNLOCK_KEY='synthetic-test-unlock-key';
const {default: download}=await import('../dist/api/images/trigger-download.js');
const {default: curated}=await import('../dist/api/images/curated.js');
const {triggerDownload}=await import('../dist/lib/unsplash.js');
let requests=[];
globalThis.fetch=async (url,options)=>{requests.push({url:String(url),options});return new Response('{}');};
const headers={'Content-Type':'application/json','X-API-Key':process.env.API_SECRET_KEY,'X-User-Id':'synthetic-user'};
const request=(url,body,extra={})=>new Request(url,{method:'POST',headers:{...headers,...extra},body:JSON.stringify(body)});
test('all photo routes expose native fetch handlers and reject unsupported methods', async()=>{
 for(const path of ['access','search','curated','curated/from-stable','proxy','trigger-download']){
  const {default: route}=await import(`../dist/api/images/${path}.js`);
  assert.equal(typeof route.fetch,'function');
  assert.equal((await route.fetch(new Request('https://test.invalid',{method:'DELETE'}))).status,405);
 }
});
test('download tracking rejects external URLs and schemes before any provider request',async()=>{
 for(const location of ['https://test.invalid/photos/example/download','http://api.unsplash.com/photos/example/download','https://api.unsplash.com.test.invalid/photos/example/download','https://user:password@api.unsplash.com/photos/example/download','https://api.unsplash.com/photos/other/download','https://api.unsplash.com:8443/photos/example/download','file:///etc/passwd']){
  assert.equal((await download.fetch(request('https://test.invalid/api/images/trigger-download',{unsplashPhotoId:'example',download_location:location}))).status,400);
 }
 assert.equal(requests.length,0);
});
test('download tracking builds exact provider URL and refuses redirects',async()=>{
 await triggerDownload('https://api.unsplash.com/photos/example/download?client_id=caller&x=arbitrary','example');
 assert.equal(requests.length,1);
 assert.equal(requests[0].url,'https://api.unsplash.com/photos/example/download');
 assert.equal(requests[0].options.redirect,'error');
 assert.equal(requests[0].options.headers.Authorization,`Client-ID ${process.env.UNSPLASH_ACCESS_KEY}`);
 globalThis.fetch=async (_url,options)=>{assert.equal(options.redirect,'error');throw new TypeError('redirect refused');};
 await assert.rejects(triggerDownload('https://api.unsplash.com/photos/example/download','example'),/redirect refused/);
});
test('curated writes require the separate unlock credential',async()=>{
 assert.equal((await curated.fetch(request('https://test.invalid/api/images/curated',{}))).status,403);
 assert.equal((await curated.fetch(request('https://test.invalid/api/images/curated',{}, {'X-Unsplash-Unlock-Key':'invalid'}))).status,403);
 assert.equal((await curated.fetch(request('https://test.invalid/api/images/curated',{}, {'X-Unsplash-Unlock-Key':process.env.UNSPLASH_UNLOCK_KEY}))).status,400);
});
