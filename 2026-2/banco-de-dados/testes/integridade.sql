\set ON_ERROR_STOP on
BEGIN;
CREATE FUNCTION pg_temp.exige(cond boolean, mensagem text) RETURNS void LANGUAGE plpgsql AS $$
BEGIN IF cond IS DISTINCT FROM true THEN RAISE EXCEPTION '%',mensagem; END IF; END $$;
CREATE FUNCTION pg_temp.rejeita(comando text, estado text) RETURNS void LANGUAGE plpgsql AS $$
BEGIN
 BEGIN EXECUTE comando;
 EXCEPTION WHEN OTHERS THEN
   IF SQLSTATE=estado THEN RETURN; END IF;
   RAISE EXCEPTION 'Estado inesperado: %, esperado %',SQLSTATE,estado;
 END;
 RAISE EXCEPTION 'Comando indevidamente aceito: %',comando;
END $$;
SELECT pg_temp.exige((SELECT count(*)=9 FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE'),'Nove tabelas');
SELECT pg_temp.exige((SELECT count(*)=9 FROM pg_constraint WHERE connamespace='public'::regnamespace AND contype='p'),'Nove chaves primárias');
SELECT pg_temp.exige((SELECT count(*)=10 FROM pg_constraint WHERE connamespace='public'::regnamespace AND contype='f'),'Dez chaves estrangeiras');
SELECT pg_temp.exige((SELECT count(*)=3 FROM pg_constraint WHERE connamespace='public'::regnamespace AND contype='u'),'Três restrições UNIQUE');
SELECT pg_temp.exige((SELECT count(*)=8 FROM pg_constraint WHERE connamespace='public'::regnamespace AND contype='c'),'Oito restrições CHECK');
SELECT pg_temp.exige((SELECT count(*)=4 FROM participacao WHERE concluida),'Quatro participações');
SELECT pg_temp.exige((SELECT count(*)=4 FROM resposta_anonima),'Quatro respostas');
SELECT pg_temp.exige((SELECT count(*)=6 FROM item_resposta),'Seis itens');
SELECT pg_temp.exige((SELECT count(*)=0 FROM token_acesso),'Tokens consumidos e desvinculados');
SELECT pg_temp.exige((SELECT count(*)=2 FROM participacao WHERE usuario_id=3),'Usuário em duas pesquisas');
SELECT pg_temp.exige((SELECT count(*)=3 FROM resposta_anonima WHERE pesquisa_id=1),'Total da pesquisa 1');
SELECT pg_temp.exige((SELECT count(*)=2 FROM resposta_anonima WHERE pesquisa_id=1 AND categoria_id=1),'Total da categoria estudantes');
SELECT pg_temp.exige((SELECT count(*)=2 FROM item_resposta i JOIN resposta_anonima r ON r.id=i.resposta_id WHERE r.pesquisa_id=1 AND r.categoria_id=1 AND i.questao_id=2 AND i.opcao_id=2),'Distribuição de alternativas');
SELECT pg_temp.rejeita('INSERT INTO participacao VALUES(1,3,1,false)','23505');
SELECT pg_temp.rejeita('INSERT INTO participacao VALUES(1,3,2,false)','23505');
SELECT pg_temp.rejeita('INSERT INTO participacao VALUES(2,4,2,false)','23503');
SELECT pg_temp.rejeita('INSERT INTO participacao VALUES(99,4,1,false)','23503');
SELECT pg_temp.rejeita('INSERT INTO participacao VALUES(1,999,1,false)','23503');
SELECT pg_temp.rejeita('INSERT INTO usuario(nome,email,senha_hash) VALUES(''X'',''a@example.invalid'',''hash'')','23505');
SELECT pg_temp.rejeita('INSERT INTO usuario(nome,email,senha_hash) VALUES(NULL,''x@example.invalid'',''hash'')','23502');
SELECT pg_temp.rejeita('INSERT INTO usuario(nome,email,senha_hash) VALUES('' '',''x@example.invalid'',''hash'')','23514');
SELECT pg_temp.rejeita('SELECT finalizar_questionario(repeat(''a'',64),''[]'')','P0001');
SELECT pg_temp.rejeita('UPDATE participacao SET concluida=false WHERE pesquisa_id=1 AND usuario_id=3','P0001');
SELECT pg_temp.rejeita('DELETE FROM participacao WHERE pesquisa_id=1 AND usuario_id=3','P0001');
SELECT pg_temp.rejeita('INSERT INTO token_acesso VALUES(repeat(''e'',64),1,3)','P0001');
SELECT pg_temp.rejeita('INSERT INTO item_resposta SELECT id,1,1 FROM resposta_anonima LIMIT 1','23505');
SELECT pg_temp.rejeita('INSERT INTO item_resposta SELECT id,99,1 FROM resposta_anonima LIMIT 1','23503');
SELECT pg_temp.rejeita('DELETE FROM opcao WHERE pesquisa_id=1','P0001');
INSERT INTO participacao VALUES(1,2,1,false);
INSERT INTO token_acesso VALUES(repeat('9',64),1,2);
SELECT pg_temp.rejeita('SELECT finalizar_questionario(repeat(''9'',64),''[{"questao_id":1,"opcao_id":1},{"questao_id":1,"opcao_id":2}]'')','23505');
SELECT pg_temp.exige((SELECT count(*)=4 FROM resposta_anonima),'Questões duplicadas desfazem resposta');
DELETE FROM token_acesso WHERE token_hash=repeat('9',64);
DELETE FROM participacao WHERE pesquisa_id=1 AND usuario_id=2;
SELECT pg_temp.exige(NOT EXISTS(SELECT 1 FROM participacao WHERE pesquisa_id=1 AND usuario_id=2),'DELETE deve remover participação ainda não concluída');
INSERT INTO participacao VALUES(2,4,1,false);
INSERT INTO token_acesso VALUES(repeat('e',64),2,4);
SELECT pg_temp.rejeita('INSERT INTO token_acesso VALUES(repeat(''7'',64),2,4)','23505');
SELECT pg_temp.rejeita('INSERT INTO token_acesso VALUES(''hash-invalido'',2,4)','23514');
SELECT pg_temp.rejeita('SELECT finalizar_questionario(repeat(''e'',64),NULL)','P0001');
SELECT pg_temp.rejeita('SELECT finalizar_questionario(repeat(''e'',64),''{}'')','P0001');
SELECT pg_temp.rejeita('SELECT finalizar_questionario(repeat(''e'',64),''[]'')','P0001');
SELECT pg_temp.rejeita('SELECT finalizar_questionario(repeat(''e'',64),''[{"questao_id":1,"opcao_id":99}]'')','23503');
SELECT pg_temp.exige((SELECT count(*)=4 FROM resposta_anonima),'Falha deve desfazer resposta');
SELECT pg_temp.exige((SELECT NOT concluida FROM participacao WHERE pesquisa_id=2 AND usuario_id=4),'Falha não consome participação');
SELECT pg_temp.exige((SELECT count(*)=1 FROM token_acesso),'Falha preserva token');
SELECT finalizar_questionario(repeat('e',64),'[{"questao_id":1,"opcao_id":1}]');
SELECT pg_temp.exige((SELECT count(*)=5 FROM resposta_anonima),'Finalização válida após falha');
SELECT pg_temp.rejeita('SELECT finalizar_questionario(repeat(''e'',64),''[{"questao_id":1,"opcao_id":1}]'')','P0001');
SELECT pg_temp.exige(NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name IN ('resposta_anonima','item_resposta') AND column_name IN ('usuario_id','token_hash','participacao_id','created_at','ip')),'Ausência estrutural de identificadores');
-- Regressão: tabelas temporárias não podem desviar a gravação da função.
INSERT INTO public.participacao VALUES(2,2,1,false);
INSERT INTO public.token_acesso VALUES(repeat('8',64),2,2);
CREATE TEMP TABLE resposta_anonima (LIKE public.resposta_anonima INCLUDING ALL);
CREATE TEMP TABLE item_resposta (LIKE public.item_resposta INCLUDING ALL);
CREATE TEMP TABLE participacao (LIKE public.participacao INCLUDING ALL);
INSERT INTO pg_temp.participacao VALUES(2,3,1,false);
SELECT pg_temp.rejeita('INSERT INTO public.token_acesso VALUES(repeat(''7'',64),2,3)','P0001');
SELECT public.finalizar_questionario(repeat('8',64),'[{"questao_id":1,"opcao_id":1}]');
SELECT pg_temp.exige((SELECT count(*)=6 FROM public.resposta_anonima),'Finalização deve gravar na tabela pública');
SELECT pg_temp.exige((SELECT count(*)=8 FROM public.item_resposta),'Itens devem ser gravados na tabela pública');
SELECT pg_temp.exige((SELECT count(*)=0 FROM pg_temp.resposta_anonima),'Tabela temporária não deve receber resposta');
SELECT pg_temp.exige((SELECT count(*)=0 FROM pg_temp.item_resposta),'Tabela temporária não deve receber itens');
SELECT pg_temp.exige((SELECT concluida FROM public.participacao WHERE pesquisa_id=2 AND usuario_id=2),'Finalização protegida conclui participação');
SELECT pg_temp.exige(NOT EXISTS(SELECT 1 FROM public.token_acesso WHERE token_hash=repeat('8',64)),'Finalização protegida consome token');
DROP TABLE pg_temp.item_resposta,pg_temp.resposta_anonima,pg_temp.participacao;
ROLLBACK;
DO $$ BEGIN
 IF (SELECT count(*) FROM public.resposta_anonima) <> 4
 OR (SELECT count(*) FROM public.item_resposta) <> 6
 OR (SELECT count(*) FROM public.participacao WHERE concluida) <> 4
 OR EXISTS(SELECT 1 FROM public.token_acesso)
 THEN RAISE EXCEPTION 'Rollback externo não preservou a carga inicial'; END IF;
END $$;
\echo 'PASSOU: integridade, anonimato estrutural, participação única, rollback e token de uso único.'
