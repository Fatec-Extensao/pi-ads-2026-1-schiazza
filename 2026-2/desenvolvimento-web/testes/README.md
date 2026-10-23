# Verificação do front-end

Verificações locais executadas em 21/10/2026 com Chromium via Playwright; versão do navegador e resultados no [JSON](./evidencias/resultado.json). As capturas em `evidencias/` documentam home, login, formulário e resultados em 360 e 1280 px. As capturas são evidência da interface; os wireframes ficam em pasta própria.

## Reproduzir

Na pasta `desenvolvimento-web/`:

```sh
python testes/validar.py
node --check src/js/app.js
npm install --no-save playwright
npx playwright install chromium
node testes/fluxos.cjs
```

O teste abre um servidor local temporário e fecha ao concluir. Playwright foi usado somente para verificação, sem dependências de produção. A execução local original usou Playwright 1.62.1.

Cobertura: 12 páginas em duas larguras, ausência de overflow da página, rótulos e alt, recursos sem erro HTTP, console sem erros de JavaScript, login inválido/válido sem credenciais na URL, datas, duplicidade, alternativas, seleção de perguntas, código fictício, campos obrigatórios, avanço/retorno preservando escolhas, conclusão única, filtros e geração fictícia. Também se verifica ausência de armazenamento local e desativação do envio sem JavaScript.

O validador Python confere links e recursos locais do HTML, unicidade de IDs, rótulos, semântica, alt e XML dos wireframes. A publicação nativa usa a branch gh-pages, gerada de src após validação local. Em 23/10/2026, a suíte também passou diretamente na URL pública, com resultados em evidencias-publicas/resultado.json.

Não são testes de backend, autenticação ou garantias de anonimato. Inspeção de acessibilidade básica e contraste das cores principais não equivale a auditoria completa WCAG.

## Reproduzir a verificação pública

Defina a variável WEB_TEST_BASE_URL como https://fatec-extensao.github.io/pi-ads-2026-1-schiazza (sem barra final) antes de executar fluxos.cjs. O teste usa apenas dados fictícios e grava o resultado e as capturas em evidencias-publicas. Omita a variável para o teste local.
