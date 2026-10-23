# Desenvolvimento Web

**Professor:** Prof. Anderson Pazin. Entrega de front-end — 21/10/2026.

Protótipo acadêmico integrado a partir de `desenvolvimentoweb.zip`, fornecido pelo usuário. Preserva as 12 páginas, o banner e a identidade visual recebidos; acrescenta JavaScript, validações, navegação por etapas e ajustes de acessibilidade e responsividade.

**Aplicação publicada e verificada em 23/10/2026:** [GitHub Pages](https://fatec-extensao.github.io/pi-ads-2026-1-schiazza/). [Código inicial](./src/index.html).

## Entregas

| Atividade | Evidência |
|---|---|
| Arquitetura e wireframes | [Sitemap e quatro SVG editáveis](./wireframes/sitemap.md) |
| HTML e CSS | [12 páginas semânticas](./src/index.html), [CSS mobile-first](./src/css/style.css), textos alternativos, rótulos e foco visível |
| JavaScript | [Validação e fluxos](./src/js/app.js): obrigatórios, formatos, datas, duplicidade na página, alternativas e seleção de perguntas |
| Navegação de questionário | Quatro etapas, avanço/retorno, preservação temporária das escolhas e confirmação final |
| Publicação | GitHub Pages nativo, com conteúdo de `src` na branch `gh-pages` |
| Verificação | [Registro e instruções](./testes/README.md), [resultados automatizados](./testes/evidencias/resultado.json) |

Issues relacionadas: [#7](https://github.com/Fatec-Extensao/pi-ads-2026-1-schiazza/issues/7), [#8](https://github.com/Fatec-Extensao/pi-ads-2026-1-schiazza/issues/8), [#9](https://github.com/Fatec-Extensao/pi-ads-2026-1-schiazza/issues/9), [#10](https://github.com/Fatec-Extensao/pi-ads-2026-1-schiazza/issues/10).

## Executar e testar

Abra `src/index.html` ou sirva `src/` com um servidor estático. Não é necessário compilar o site nem instalar dependências para usá-lo. Para testar: consulte [testes](./testes/README.md).

## Limites da entrega

Os formulários validam e simulam ações no navegador. Não há autenticação real, banco, API, envio ou armazenamento de dados. O código fictício `DEMO-2026` serve apenas para percorrer o questionário. Login com formato válido abre o painel, que também é acessível pela navegação. Geração de códigos e cadastros não têm validade fora da página. Relatórios e monitoramento usam exemplos fictícios fixos, não respostas coletadas.

Credenciais não são enviadas por GET, não aparecem na URL e não são guardadas em localStorage, sessionStorage ou cookies. Sem JavaScript, os formulários ficam desativados. A identidade visual recebida foi preservada; o CSS foi reorganizado para partir das telas menores.

A integração com banco e regras de anonimato exige backend, autorização, transações e revisão de segurança. O formulário aberto e as alternativas do ZIP são demonstrações de interface; não modificam o escopo do modelo de dados de cada projeto. A conclusão técnica desta disciplina não representa conclusão do PI nem aprovação acadêmica.

## Situação da publicação

Publicado em https://fatec-extensao.github.io/pi-ads-2026-1-schiazza/ pelo modo nativo do GitHub Pages. A configuração anterior por workflow foi substituída pela publicação da branch gh-pages. O endereço retornou HTTP 200 e a suíte de navegador passou nas 12 páginas em 360 e 1280 px, incluindo recursos estáticos, navegação e formulários demonstrativos.

[Resultados públicos](./testes/evidencias-publicas/resultado.json) · [Registro da publicação](./testes/evidencias/publicacao.json).

GitHub Actions permanece desativado na organização; a publicação nativa foi verificada sem alterar essa política. Para atualizar o site, valide as fontes, execute git subtree split --prefix=2026-2/desenvolvimento-web/src na raiz e publique o SHA retornado na branch gh-pages. Não envie credenciais nem outros diretórios para essa branch.
