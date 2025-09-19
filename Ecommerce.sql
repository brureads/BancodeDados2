CREATE TABLE Cliente (
    id_cliente SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    cpf CHAR(11) UNIQUE NOT NULL,
    data_nascimento DATE,
    sexo VARCHAR(10) CHECK (sexo IN ('F', 'M', 'Outro')),
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Produto (
    id_produto SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco NUMERIC(10,2) NOT NULL,
    categoria VARCHAR(50),
    imagem_url VARCHAR(255)
);

CREATE TABLE Pedido (
    id_pedido SERIAL PRIMARY KEY,
    id_cliente INT NOT NULL,
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) CHECK (status IN ('Em Processamento', 'Enviado', 'Entregue', 'Cancelado')) DEFAULT 'Em Processamento',
    endereco_entrega TEXT,
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
);

CREATE TABLE ItemPedido (
    id_pedido INT,
    id_produto INT,
    quantidade INT NOT NULL,
    preco_unitario NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (id_pedido, id_produto),
    FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido),
    FOREIGN KEY (id_produto) REFERENCES Produto(id_produto)
);

CREATE TABLE FormaPagamento (
    id_pagamento SERIAL PRIMARY KEY,
    id_pedido INT NOT NULL,
    tipo VARCHAR(10) CHECK (tipo IN ('Cartao', 'Pix', 'Boleto')) NOT NULL,
    status VARCHAR(10) CHECK (status IN ('Pendente', 'Pago', 'Cancelado')) DEFAULT 'Pendente',
    FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido)
);

CREATE TABLE Estoque (
    id_produto INT PRIMARY KEY,
    quantidade INT NOT NULL,
    localizacao VARCHAR(100),
    FOREIGN KEY (id_produto) REFERENCES Produto(id_produto)
);

-- DADOS

INSERT INTO Cliente (nome, email, cpf, data_nascimento, sexo)
VALUES 
('Bruna Silva', 'bruna@email.com', '12345678901', '2003-05-12', 'F'),
('Carlos Souza', 'carlos@email.com', '23456789012', '1998-09-20', 'M'),
('Ana Lima', 'ana@email.com', '34567890123', '2000-01-30', 'F'),
('Lucas Freitas', 'lucas@email.com', '45678901234', '1995-07-08', 'M'),
('Juliana Costa', 'juliana@email.com', '56789012345', '2002-11-15', 'F');

INSERT INTO Produto (nome, descricao, preco, categoria)
VALUES
('Camiseta', 'Camiseta rosa', 59.90, 'Roupas'),
('Caneca Rosa Pastel', 'Caneca para café ou chá', 39.00, 'Utensílios'),
('Mochila', 'Mochila grande com compartimento para notebook', 120.50, 'Acessórios'),
('Fone Bluetooth', 'Fone sem fio com som estéreo', 199.90, 'Eletrônicos'),
('Planner Estudante', 'Planner 2025 com adesivos', 45.00, 'Papelaria');

INSERT INTO Estoque (id_produto, quantidade, localizacao)
VALUES
(1, 100, 'Estoque A1'),
(2, 80, 'Estoque B2'),
(3, 50, 'Estoque C3'),
(4, 40, 'Estoque A2'),
(5, 70, 'Estoque B1');

INSERT INTO Pedido (id_cliente, data_pedido, status, endereco_entrega)
VALUES
(1, NOW(), 'Em Processamento', 'Rua das Flores, 123'),
(2, NOW(), 'Enviado', 'Av. Central, 456'),
(3, NOW(), 'Entregue', 'Rua das Acácias, 789'),
(4, NOW(), 'Cancelado', 'Rua Tutu, 101'),
(5, NOW(), 'Em Processamento', 'Rua dos Gatinhos, 202');

INSERT INTO ItemPedido (id_pedido, id_produto, quantidade, preco_unitario)
VALUES
(1, 1, 2, 59.90),
(1, 2, 1, 39.00),
(2, 3, 1, 120.50),
(3, 4, 1, 199.90),
(4, 5, 2, 45.00);

INSERT INTO FormaPagamento (id_pedido, tipo, status)
VALUES
(1, 'Cartao', 'Pendente'),
(2, 'Pix', 'Pago'),
(3, 'Boleto', 'Pago'),
(4, 'Cartao', 'Cancelado'),
(5, 'Pix', 'Pendente');

CREATE OR REPLACE FUNCTION produto_mais_vendido()
RETURNS TABLE(
    id_produto INT,
    nome VARCHAR,
    total_vendido INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id_produto,
        p.nome,
        SUM(i.quantidade) AS total_vendido
    FROM produto p
    JOIN itempedido i ON p.id_produto = i.id_produto
    GROUP BY p.id_produto, p.nome
    ORDER BY total_vendido DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS produto_mais_vendido();

CREATE OR REPLACE FUNCTION produto_mais_vendido()
RETURNS TABLE(produto VARCHAR, total_vendido INT) AS $$
BEGIN
    RETURN QUERY
    SELECT p.nome, SUM(i.quantidade) AS total_vendido
    FROM itempedido i
    JOIN produto p ON i.id_produto = p.id_produto
    GROUP BY p.nome
    ORDER BY total_vendido DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION situacao_estoque()
RETURNS TABLE(produto VARCHAR, quantidade INT, localizacao VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT p.nome, e.quantidade, e.localizacao
    FROM estoque e
    JOIN produto p ON e.id_produto = p.id_produto
    ORDER BY e.quantidade ASC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION melhor_cliente()
RETURNS TABLE(cliente VARCHAR, total_gasto NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT c.nome, SUM(i.quantidade * i.preco_unitario) AS total_gasto
    FROM cliente c
    JOIN pedido p ON c.id_cliente = p.id_cliente
    JOIN itempedido i ON p.id_pedido = i.id_pedido
    GROUP BY c.nome
    ORDER BY total_gasto DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS produto_mais_vendido();

CREATE FUNCTION produto_mais_vendido()
RETURNS TABLE(nome TEXT, total_vendido BIGINT)
AS $$
BEGIN
    RETURN QUERY
    SELECT p.nome, SUM(i.quantidade) AS total_vendido
    FROM itempedido i
    JOIN produto p ON i.id_produto = p.id_produto
    GROUP BY p.nome
    ORDER BY total_vendido DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS produto_mais_vendido();

CREATE OR REPLACE FUNCTION produto_mais_vendido()
RETURNS TABLE(nome VARCHAR, total_vendido BIGINT)
AS $$
BEGIN
    RETURN QUERY
    SELECT p.nome, SUM(i.quantidade) AS total_vendido
    FROM itempedido i
    JOIN produto p ON i.id_produto = p.id_produto
    GROUP BY p.nome
    ORDER BY total_vendido DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;
	