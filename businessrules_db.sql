DELIMITER //
CREATE TRIGGER trg_gerenciar_endereco_padrao
BEFORE INSERT ON Enderecos_Cliente
FOR EACH ROW
BEGIN
    DECLARE is_principal_exists INT;

    SELECT COUNT(*)
    INTO is_principal_exists
    FROM Enderecos_Cliente
    WHERE s_cpf_Cliente = NEW.s_cpf_Cliente
      AND b_enderecoP_EnderecosCliente = 1;

    -- Se tenta inserir '1' mas já existe '1', força o novo para '0'.
    IF NEW.b_enderecoP_EnderecosCliente = 1 AND is_principal_exists > 0 THEN
        SET NEW.b_enderecoP_EnderecosCliente = 0;

    -- Se tenta inserir '0' e NENHUM existe, promove o novo para '1' (promove o primeiro).
    ELSEIF NEW.b_enderecoP_EnderecosCliente = 0 AND is_principal_exists = 0 THEN
        SET NEW.b_enderecoP_EnderecosCliente = 1;
    END IF;
END;
//

DELIMITER //
CREATE TRIGGER trg_item_venda_validacao
BEFORE INSERT ON Item_Venda
FOR EACH ROW
BEGIN
    DECLARE v_estoque_disponivel INT;
    DECLARE v_custo DECIMAL(10,2);
    DECLARE v_lucro DECIMAL(5,2);
    DECLARE v_endereco_padrao VARCHAR(500);

    -- Busca dados do Produto (Estoque e valores)
    SELECT i_qtd_Produto, f_valorCusto_Produto, f_percentLucro_Produto
    INTO v_estoque_disponivel, v_custo, v_lucro
    FROM Produto WHERE i_id_Produto = NEW.i_id_Produto;

    -- RN: Validação de Estoque (Impede a venda se faltar estoque)
    IF NEW.i_qtdTotal_ItemVenda > v_estoque_disponivel THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERRO: A quantidade vendida excede o estoque disponível do produto.';
    END IF;

    -- RN: Cálculo do Preço de Venda
    SET NEW.f_valorUnitario_ItemVenda = v_custo * (1 + v_lucro / 100);

    -- RN: Puxa Endereço Padrão do Cliente para a entrega
    SELECT CONCAT(s_rua_EnderecosCliente, ' Nº ', i_numero_EnderecosCliente, ', ',
                  s_cidade_EnderecosCliente, ' - ', s_estado_EnderecosCliente)
    INTO v_endereco_padrao
    FROM Enderecos_Cliente
    WHERE s_cpf_Cliente = NEW.s_cpf_Cliente AND b_enderecoP_EnderecosCliente = 1;

    SET NEW.s_enderecoentrega_ItemVenda = v_endereco_padrao;
END;
//

DELIMITER //
CREATE TRIGGER trg_estoque_venda
AFTER INSERT ON Item_Venda
FOR EACH ROW
BEGIN
    UPDATE Produto
    SET i_qtd_Produto = i_qtd_Produto - NEW.i_qtdTotal_ItemVenda
    WHERE i_id_Produto = NEW.i_id_Produto;
END;
//

DELIMITER //
CREATE TRIGGER trg_item_compra_validacao
BEFORE INSERT ON Item_Compra
FOR EACH ROW
BEGIN
    DECLARE v_pode_fornecer INT;

    -- Verifica o relacionamento M:N em Fornecedor_has_Produto
    SELECT COUNT(*)
    INTO v_pode_fornecer
    FROM Fornecedor_has_Produto
    WHERE i_id_Produto = NEW.i_id_Produto AND s_cnpj_Fornecedor = NEW.s_cnpj_Fornecedor;

    -- Se não for autorizado, CANCELA a compra.
    IF v_pode_fornecer = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERRO: O fornecedor especificado não está cadastrado como fornecedor deste produto.';
    END IF;
END;
//


DELIMITER //
CREATE TRIGGER trg_estoque_compra
AFTER INSERT ON Item_Compra
FOR EACH ROW
BEGIN
    UPDATE Produto
    SET i_qtd_Produto = i_qtd_Produto + NEW.i_qtdTotal_ItemCompra
    WHERE i_id_Produto = NEW.i_id_Produto;
END;
//