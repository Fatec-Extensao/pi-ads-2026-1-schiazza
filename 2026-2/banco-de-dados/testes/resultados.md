# Evidências de validação

Ambiente: Windows, PostgreSQL **18.6**, servidor descartável em 127.0.0.1:55456, usuário pi_test. O banco existente na porta 5432 não foi utilizado. Versão obtida por `SELECT version()`. psql executado com `-X -v ON_ERROR_STOP=1`; saídas anexas geradas em banco novo na ordem do README, somente com dados fictícios.

| Verificação | Resultado observado |
| --- | --- |
| schema.sql | Transação concluída; nove tabelas e funções/gatilhos criados |
| Carga DML | 5 usuários, 2 pesquisas, 3 categorias, 4 questões, 8 opções |
| Finalizações | 4 participações, 4 respostas, 6 itens, zero tokens ativos |
| JOIN / COUNT / GROUP BY | Quatro consultas executadas; totais por pesquisa: 3 e 1; categoria: 2, 1 e 1 |
| Alternativas | Oito linhas; alternativas sem votos preservadas com zero |
| Participação repetida | Rejeitada com 23505 |
| Usuário em pesquisas diferentes | Aceito; duas participações para o mesmo usuário |
| Referências inexistentes | Rejeitadas com 23503 |
| NULL, vazio e email repetido | Rejeitados com 23502, 23514 e 23505 |
| Opção inválida / questão repetida | Rejeitadas; inserção da resposta revertida |
| Finalização incompleta | Rejeitada; token preservado, participação não concluída |
| Reuso de token | Rejeitado após consumo |
| Reabrir/excluir participação concluída | Rejeitado por gatilho |
| Emitir token após conclusão | Rejeitado por gatilho |
| Excluir opção | Rejeitado por imutabilidade |
| Anonimato estrutural | Sem usuario_id, token_hash, participacao_id, created_at ou ip em respostas/itens |
| Concorrência | Duas sessões: um sucesso, uma rejeição; totais finais: 5 respostas, 7 itens, zero tokens |
| DER PNG | Inspecionado visualmente após correção de codificação; legível e sem cortes |

`integridade.sql` verifica assertions e SQLSTATE das falhas esperadas. Seu ROLLBACK preserva a carga inicial. `concorrencia.ps1` usa dois processos psql e mantém bloqueio com pg_sleep(2); exige um sucesso e verifica contagens. A fixture adicional explica o aumento de quatro para cinco respostas. Os scripts exigem banco novo para repetição.

Evidências: [SQL](execucao-sql.txt) e [concorrência](execucao-concorrencia.txt). Falhas esperadas são capturadas pelos testes. Não foram implementados/testados backend, entrega de resultados, geração de credenciais, política de permissões ou anonimato contra operadores privilegiados.
