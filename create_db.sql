CREATE DATABASE TrabalhoFinalFinal;

create table Loja(
	s_cnpj_Loja varchar(14) primary key not null,
    s_nome_Loja varchar(45) not null
);


create table Telefones_Loja(
	s_telefone_TelefonesLoja varchar(15)  not null,
    s_cnpj_Loja varchar(14) not null,
    primary key(s_telefone_TelefonesLoja, s_cnpj_Loja),
    /* ============================ Restrições ========================== */
    constraint fk_TelefonesLoja_Loja foreign key(s_cnpj_Loja) references Loja(s_cnpj_Loja)
);


create table Emails_Loja(
	s_email_EmailsLoja varchar(50) not null,
    s_cnpj_Loja varchar(14) not null,
    primary key(s_email_EmailsLoja, s_cnpj_Loja),
    /* ============================ Restrições ========================== */
    constraint fk_EmailsLoja_Loja foreign key(s_cnpj_Loja) references Loja(s_cnpj_Loja)
);


create table Produto(
	i_id_Produto int primary key auto_increment,
    s_nome_Produto varchar(45) not null,
    s_tipo_Produto varchar(45) not null,
    s_cor_Produto varchar(45) not null,
    s_dsc_Produto longtext not null,
    s_caract_Produto longtext not null,
    i_qtd_Produto int not null,
    f_percentLucro_Produto decimal(5,2),
    f_valorCusto_Produto decimal(10,2),
    s_UrlFotoP_Produto varchar(2000),
    s_cnpj_Loja varchar(14) not null,
    /* ============================ Restrições ========================== */
    constraint fk_Produdto_Loja foreign key(s_cnpj_Loja) references Loja(s_cnpj_Loja)
);


create table Fotos_Complementares(
	i_id_FotosComplementares int primary key auto_increment,
    s_UrlFotoC_FotosComplementares varchar(2000) not null,
    i_id_Produto int not null,
     /* ============================ Restrições ========================== */
    constraint fk_FotosComplementares_Produto foreign key(i_id_Produto) references Produto(i_id_Produto)
);


create table Fornecedor(
	s_cnpj_Fornecedor varchar(14) primary key not null,
    s_nome_Fornecedor varchar(45) not null,
    d_dataRegistro_Fornecedor timestamp not null default current_timestamp,
    s_cnpj_Loja varchar(14) not null,
    /* ============================ Restrições ========================== */
    constraint fk_Fornecedor_Loja foreign key(s_cnpj_Loja) references Loja(s_cnpj_Loja)
);


create table Enderecos_Fornecedor(
	s_estado_EnderecosFornecedor varchar(2) not null,
    s_cidade_EnderecosFornecedor varchar(100) not null,
    s_rua_EnderecosFornecedor varchar(100) not null,
    i_numero_EnderecosFornecedor int not null,
    s_cnpj_Fornecedor varchar(14) not null,
    primary key(s_estado_EnderecosFornecedor, s_cidade_EnderecosFornecedor, s_rua_EnderecosFornecedor, i_numero_EnderecosFornecedor, s_cnpj_Fornecedor),
    /* ============================ Restrições ========================== */
    constraint fk_EnderecosFornecedor_Fornecedor foreign key(s_cnpj_Fornecedor) references Fornecedor(s_cnpj_Fornecedor)
);


create table Emails_Fornecedor(
	s_email_EmailsFornecedor varchar(50) not null,
	s_cnpj_Fornecedor varchar(14) not null,
    primary key(s_email_EmailsFornecedor, s_cnpj_Fornecedor),
	/* ============================ Restrições ========================== */
    constraint fk_EmailsFornecedor_Fornecedor foreign key(s_cnpj_Fornecedor) references Fornecedor(s_cnpj_Fornecedor)
);


create table Telefones_Fornecedor(
	s_telefone_TelefonesFornecedor varchar(15) not null,
    s_cnpj_Fornecedor varchar(14) not null,
    primary key(s_telefone_TelefonesFornecedor, s_cnpj_Fornecedor),
    /* ============================ Restrições ========================== */
    constraint fk_TelefonesFornecedor_Fornecedor foreign key(s_cnpj_Fornecedor) references Fornecedor(s_cnpj_Fornecedor)
);


create table Fornecedor_has_Produto(
	i_id_Produto int not null,
    s_cnpj_Fornecedor varchar(14) not null,
    primary key(i_id_Produto, s_cnpj_Fornecedor),
    /* ============================ Restrições ========================== */
    constraint fk_FornecedorHasProduto_Produto foreign key(i_id_Produto) references Produto(i_id_Produto),
    constraint fk_FornecedorHasProduto_Fornecedor foreign key(s_cnpj_Fornecedor) references Fornecedor(s_cnpj_Fornecedor)
);


create table Cliente(
	s_cpf_Cliente varchar(11) primary key not null,
    s_nome_Cliente varchar(45) not null,
    b_msgPromo_Cliente enum("Aceito", "Não Aceito") not null default "Aceito",
	d_dataRegistro_Cliente timestamp not null default current_timestamp,
    s_cnpj_Loja varchar(14) not null,
    /* ============================ Restrições ========================== */
    constraint fk_Cliente_Loja foreign key(s_cnpj_Loja) references Loja(s_cnpj_Loja)
);


create table Enderecos_Cliente(
	s_estado_EnderecosCliente varchar(2) not null,
    s_cidade_EnderecosCliente varchar(100) not null,
    s_rua_EnderecosCliente varchar(100) not null,
    i_numero_EnderecosCliente int not null,
    s_cpf_Cliente varchar(11) not null,
    b_enderecoP_EnderecosCliente tinyint(1) not null default 0,
    -- 1 significa Endereço Padrão/Principal
    -- 0 significa Endereço Secundário
    -- Ela garante que cada cliente tenha no máximo um endereço de entrega padrão.
    primary key(s_estado_EnderecosCliente, s_cidade_EnderecosCliente, s_rua_EnderecosCliente, i_numero_EnderecosCliente, s_cpf_Cliente),
	/* ============================ Restrições ========================== */
	constraint fk_EnderecosCliente_Cliente foreign key(s_cpf_Cliente) references Cliente(s_cpf_Cliente),
    -- Garante que apenas UM registro por cliente tenha b_endereco_Principal = 1
    -- Regra de Negócio: "um cliente pode ter um e apenas um endereço de entrega padrão"
    UNIQUE INDEX uk_unico_endereco_principal (s_cpf_Cliente, b_enderecoP_EnderecosCliente)
);

create table Telefone_Cliente(
	s_telefone_TelefoneCliente varchar(15) not null,
    s_cpf_Cliente varchar(11) not null,
    primary key(s_telefone_TelefoneCliente, s_cpf_Cliente),
	/* ============================ Restrições ========================== */
	constraint fk_TelefoneCliente_Cliente foreign key(s_cpf_Cliente) references Cliente(s_cpf_Cliente)
);


create table Operacao(
	i_id_Operacao int auto_increment,
    s_formaPagamento_Operacao varchar(45) not null,
    d_data_Operacao timestamp not null default current_timestamp,
    s_tipo_Operacao varchar(45) not null,
    s_cnpj_Loja varchar(14) not null,
    primary key(i_id_Operacao),
    /* ============================ Restrições ========================== */
    constraint fk_Operacao_Loja foreign key(s_cnpj_Loja) references Loja(s_cnpj_Loja)
);


create table Item_Venda(
	i_id_ItemVenda int primary key auto_increment,
    i_qtdTotal_ItemVenda int not null,
    f_valorUnitario_ItemVenda decimal (10,2), -- trigger
    s_enderecoentrega_ItemVenda varchar(200), -- trigger
    i_id_Operacao int not null,
    i_id_Produto int not null,
    s_cpf_Cliente varchar(11) not null,
    /* ============================ Restrições ========================== */
    constraint fk_ItemVenda_Operacao foreign key(i_id_Operacao) references Operacao(i_id_Operacao),
    constraint fk_ItemVenda_Produto foreign key(i_id_Produto) references Produto(i_id_Produto),
    constraint fk_ItemVenda_Cliente foreign key(s_cpf_Cliente) references Cliente(s_cpf_Cliente)
);


create table Item_Compra(
	i_id_ItemCompra int primary key auto_increment,
    i_qtdTotal_ItemCompra int not null,
    f_valorUnitario_ItemCompra decimal(10,2),
    i_id_Operacao int not null,
    i_id_Produto int not null,
    s_cnpj_Fornecedor varchar(14) not null,
    /* ============================ Restrições ========================== */
    constraint fk_ItemCompra_Operacao foreign key(i_id_Operacao) references Operacao(i_id_Operacao),
    constraint fk_ItemCompra_Produto foreign key(i_id_Produto) references Produto(i_id_Produto),
    constraint fk_ItemCompra_Fornecedor foreign key(s_cnpj_Fornecedor) references Fornecedor(s_cnpj_Fornecedor)
);
