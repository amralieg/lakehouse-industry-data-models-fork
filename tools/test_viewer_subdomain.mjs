import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import assert from 'assert';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const html = fs.readFileSync(path.join(root, 'docs/index.html'), 'utf8');
const start = html.indexOf('function calcDomainViewPositions');
const end = html.indexOf('// ── Cytoscape stylesheet');
assert.ok(start >= 0 && end > start, 'scope helpers missing');
const api = new Function(`${html.slice(start, end)}\nreturn {buildDomainScopeElements,subdomainNodeId,viewFilterKey};`)();

const tablesByDomain = {
  sales: [
    {data: {id: 'sales.order', subdomain: 'checkout'}, classes: 'table-node'},
    {data: {id: 'sales.cart', subdomain: 'checkout'}, classes: 'table-node'},
    {data: {id: 'sales.campaign', subdomain: 'marketing'}, classes: 'table-node'},
  ],
};
const domainByName = {sales: {data: {id: 'domain_sales', type: 'domain', color: '#111'}}};
const domainHierarchy = {sales: {subdomains: {checkout: {}, marketing: {}}}};
const edges = [
  {data: {id: 'e1', source: 'sales.order', target: 'sales.cart'}},
  {data: {id: 'e2', source: 'sales.order', target: 'sales.campaign'}},
];

const domainEls = api.buildDomainScopeElements('sales', null, domainHierarchy, domainByName, tablesByDomain, edges, () => ({color: '#0f0'}));
const domainTables = domainEls.filter(e => (e.classes || '').includes('table-node')).map(e => e.data.id).sort();
assert.deepEqual(domainTables, ['sales.campaign', 'sales.cart', 'sales.order']);

const subEls = api.buildDomainScopeElements('sales', 'checkout', domainHierarchy, domainByName, tablesByDomain, edges, () => ({color: '#0f0'}));
const subTables = subEls.filter(e => (e.classes || '').includes('table-node')).map(e => e.data.id).sort();
assert.deepEqual(subTables, ['sales.cart', 'sales.order']);
assert.ok(subEls.some(e => e.data && e.data.type === 'subdomain' && e.data.subdomain === 'checkout'));
assert.ok(!subEls.some(e => e.data && e.data.id === 'sales.campaign'));
assert.ok(subEls.some(e => e.data && e.data.source === 'sales.order' && e.data.target === 'sales.cart'));
assert.ok(!subEls.some(e => e.data && e.data.target === 'sales.campaign'));

assert.equal(api.viewFilterKey('subdomain', {domain: 'sales', subdomain: 'checkout'}),
  'subdomain::{"domain":"sales","subdomain":"checkout"}');
assert.ok(html.includes("type==='subdomain'"));
assert.ok(html.includes('onClickSubdomain'));
assert.ok(html.includes("left:15") && html.includes('Download PNG'));
assert.ok(!/bottom:\s*15,\s*left:\s*15[\s\S]{0,200}Download PNG/.test(html));

console.log('ok', {domainTables: domainTables.length, subTables: subTables.length});
