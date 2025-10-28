CREATE DATABASE aula10;
USE aula10;

CREATE TABLE cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100)
);

CREATE TABLE pedido (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    data_pedido DATETIME,
    valor_total DECIMAL(10,2),
    status VARCHAR(50),
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
);

CREATE TABLE pagamento (
    id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT,
    valor DECIMAL(10,2),
    forma_pagamento VARCHAR(50),
    data_pagamento DATETIME,
    status VARCHAR(50),
    FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido)
);

INSERT INTO cliente (nome)
VALUES ('Bruna');

SELECT * FROM cliente;

DELIMITER $$

CREATE PROCEDURE pedido_com_pagamento(
    IN p_id_cliente INT,
    IN p_valor DECIMAL(10,2),
    IN p_forma_pagamento VARCHAR(50)
)
BEGIN
    DECLARE v_id_pedido INT;
    
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT '❌ Falha na transação: pedido e pagamento cancelados.' AS mensagem;
    END;

    
    START TRANSACTION;

   
    IF (SELECT COUNT(*) FROM cliente WHERE id_cliente = p_id_cliente) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cliente não encontrado.';
    END IF;


    IF p_valor <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Valor deve ser maior que zero.';
    END IF;

 
    INSERT INTO pedido (id_cliente, data_pedido, valor_total, status)
    VALUES (p_id_cliente, NOW(), p_valor, 'aguardando_pagamento');

    SET v_id_pedido = LAST_INSERT_ID();

   
    INSERT INTO pagamento (id_pedido, valor, forma_pagamento, data_pagamento, status)
    VALUES (v_id_pedido, p_valor, p_forma_pagamento, NOW(), 'aprovado');

   
    UPDATE pedido
    SET status = 'confirmado'
    WHERE id_pedido = v_id_pedido;

   
    COMMIT;

    
    SELECT CONCAT('✅ Pedido ', v_id_pedido, ' criado e pago com sucesso!') AS mensagem;
END $$

DELIMITER ;

-- hora de testar se deu tudo certinho!!

CALL pedido_com_pagamento(1, 250.00, 'Cartão');

SELECT * FROM pedido;
SELECT * FROM pagamento;
