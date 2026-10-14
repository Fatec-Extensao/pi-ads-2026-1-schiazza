// Validação documental local: node 2026-2/engenharia-software/modelagem-uml/validar.cjs
// Não substitui renderização PlantUML, revisão visual nem testes do backend.
const fs = require('fs');
const path = require('path');
const assert = require('assert/strict');
const dir = __dirname;
const sources = ['casos-de-uso/casos-de-uso','classes/classes','sequencia/responder-questionario'];
for (const file of sources) {
  const src = fs.readFileSync(path.join(dir,file+'.puml'),'utf8');
  const svg = fs.readFileSync(path.join(dir,file+'.svg'),'utf8');
  assert(src.startsWith('@startuml') && src.trimEnd().endsWith('@enduml'), file);
  assert(svg.includes('<svg') && svg.includes('</svg>'), file+' SVG ausente');
  assert(!/Syntax Error|An error has occurred/i.test(svg), file+' erro de renderização');
  assert(!svg.includes('\uFFFD'), file+' codificação');
}
const requirements = fs.readFileSync(path.join(dir,'../requisitos.md'),'utf8');
for(let i=1;i<=10;i++) assert(requirements.includes('RF'+String(i).padStart(2,'0')));
for(let i=1;i<=9;i++) assert(requirements.includes('RNF'+String(i).padStart(2,'0')));
const usecases = fs.readFileSync(path.join(dir,sources[0]+'.puml'),'utf8');
assert.equal((usecases.match(/^actor /gm)||[]).length,3);
for(let i=1;i<=10;i++) assert(usecases.includes('UC'+String(i).padStart(2,'0')));
const classes = fs.readFileSync(path.join(dir,sources[1]+'.puml'),'utf8');
assert.equal((classes.match(/^class /gm)||[]).length,9);
assert(!/^.*(?:Usuario|Participacao|TokenAcesso).*--.*Resposta\s*:/m.test(classes),'Ligação identidade–resposta');
const sequence = fs.readFileSync(path.join(dir,sources[2]+'.puml'),'utf8');
for(const marker of ['FOR UPDATE','ROLLBACK','COMMIT','DELETE token_acesso','finalizar_questionario','loop para cada questão']) assert(sequence.includes(marker),marker);
function checkLinks(folder) {
  for(const entry of fs.readdirSync(folder,{withFileTypes:true})) {
    const full=path.join(folder,entry.name);
    if(entry.isDirectory()) checkLinks(full);
    else if(entry.name.endsWith('.md')) {
      const markdown = fs.readFileSync(full,'utf8').replace(/```[\s\S]*?```/g,'');
      for(const match of markdown.matchAll(/\]\(([^)]+)\)/g)) {
        const link=match[1];
        if(!/^(https?:|#)/.test(link)) assert(fs.existsSync(path.resolve(folder,link.split('#')[0])),full+': '+link);
      }
    }
  }
}
checkLinks(path.join(dir,'..'));
console.log('PASSOU: 3 fontes/SVG, 3 atores, 10 UC, 9 classes, 10 RF, 9 RNF, contrato transacional e links locais.');
