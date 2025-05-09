-- Remoção de tabelas em ordem correta (considerando dependências)
DROP TABLE  pagamentos cascade;
DROP TABLE  manutencoes cascade;
DROP TABLE  locacoes cascade;
DROP TABLE  veiculos cascade;
DROP TABLE  clientes cascade;

-- Criação da tabela de clientes
CREATE TABLE clientes (
    cliente_id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    telefone VARCHAR(15) NOT NULL,
    email VARCHAR(100) UNIQUE,
    endereco VARCHAR(200) NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'ATIVO' CHECK (status IN ('ATIVO', 'INATIVO', 'BLOQUEADO'))
);

-- Criação da tabela de veículos
CREATE TABLE veiculos (
    veiculo_id SERIAL PRIMARY KEY,
    placa VARCHAR(10) UNIQUE NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    marca VARCHAR(50) NOT NULL,
    ano INTEGER NOT NULL CHECK (ano > 1900 AND ano <= EXTRACT(YEAR FROM CURRENT_DATE) + 1),
    tipo VARCHAR(10) NOT NULL CHECK (tipo IN ('CARRO', 'MOTO')),
    cor VARCHAR(30),
    disponivel BOOLEAN DEFAULT TRUE,
    valor_diaria DECIMAL(10, 2) NOT NULL CHECK (valor_diaria > 0),
    quilometragem INTEGER DEFAULT 0,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Criação da tabela de locações
CREATE TABLE locacoes (
    locacao_id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL REFERENCES clientes(cliente_id),
    veiculo_id INTEGER NOT NULL REFERENCES veiculos(veiculo_id),
    data_locacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_devolucao_prevista DATE NOT NULL,
    data_devolucao_real DATE,
    valor_total DECIMAL(10, 2) CHECK (valor_total > 0),
    status VARCHAR(20) NOT NULL CHECK (status IN ('ATIVA', 'FINALIZADA', 'CANCELADA')),
    observacoes TEXT,
    CONSTRAINT check_datas CHECK (data_devolucao_prevista >= DATE(data_locacao)),
    CONSTRAINT check_devolucao_real CHECK (
        (data_devolucao_real IS NULL AND status = 'ATIVA') OR
        (data_devolucao_real IS NOT NULL AND status IN ('FINALIZADA', 'CANCELADA'))
    )
);

-- Criação da tabela de pagamentos
CREATE TABLE pagamentos (
    pagamento_id SERIAL PRIMARY KEY,
    locacao_id INTEGER NOT NULL REFERENCES locacoes(locacao_id),
    forma_pagamento VARCHAR(20) NOT NULL CHECK (forma_pagamento IN ('CRÉDITO', 'DÉBITO', 'PIX', 'DINHEIRO', 'TRANSFERÊNCIA')),
    valor_pago DECIMAL(10, 2) NOT NULL CHECK (valor_pago > 0),
    data_pagamento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'CONFIRMADO' CHECK (status IN ('CONFIRMADO', 'PENDENTE', 'ESTORNADO')),
    codigo_transacao VARCHAR(50),
    observacoes TEXT
);

-- Criação da tabela de manutenções
CREATE TABLE manutencoes (
    manutencao_id SERIAL PRIMARY KEY,
    veiculo_id INTEGER NOT NULL REFERENCES veiculos(veiculo_id),
    data_inicio DATE NOT NULL,
    data_fim DATE,
    descricao VARCHAR(200) NOT NULL,
    custo DECIMAL(10, 2) CHECK (custo >= 0),
    tipo VARCHAR(30) CHECK (tipo IN ('PREVENTIVA', 'CORRETIVA', 'PINTURA', 'FUNILARIA')),
    responsavel VARCHAR(100),
    CONSTRAINT check_data_manutencao CHECK (data_fim IS NULL OR data_fim >= data_inicio)
);

-- Populando a tabela de clientes (com dados melhorados)
INSERT INTO clientes (nome, cpf, telefone, email, endereco)
VALUES
    ('João Silva', '123.456.789-00', '(11) 99999-9999', 'joao@email.com', 'Rua A, 123 - São Paulo/SP'),
    ('Maria Souza', '987.654.321-00', '(11) 88888-8888', 'maria@email.com', 'Av. B, 456 - Rio de Janeiro/RJ'),
    ('Carlos Oliveira', '456.789.123-00', '(11) 77777-7777', 'carlos@email.com', 'Rua C, 789 - Belo Horizonte/MG'),
    ('Davi Brito', '457.356.349-00', '(11) 55555-5555', 'davi@email.com', 'Rua D, 2483 - Curitiba/PR'),
    ('Mariana Valente', '087.784.381-00', '(11) 33333-3333', 'marianav@email.com', 'Av. E, 206 - Porto Alegre/RS'),
    ('Camila Soares', '136.232.233-00', '(11) 22222-2222', 'camilas@email.com', 'Rua F, 5789 - Salvador/BA'),
    ('Felipe Fontenele', '458.348.768-00', '(11) 34465-9809', 'felipe@email.com', 'Av. G, 1134 - Brasília/DF'),
    ('Valéria Mendes', '536.467.571-00', '(11) 88888-8888', 'valeria@email.com', 'Rua H, 456 - Florianópolis/SC'),
    ('Paulo Pereira', '466.356.356-00', '(11) 11111-1111', 'paulo@email.com', 'Alameda I, 724 - Recife/PE'),
    ('Ruan Bandeira', '545.336.239-00', '(11) 44444-4444', 'ruan@email.com', 'Rua J, 4533 - Manaus/AM');

-- Populando a tabela de veículos (com mais detalhes)
INSERT INTO veiculos (placa, modelo, marca, ano, tipo, cor, disponivel, valor_diaria, quilometragem)
VALUES
    ('ABC1D23', 'Gol', 'Volkswagen', 2020, 'CARRO', 'Branco', TRUE, 150.00, 12500),
    ('XYZ5E78', 'Civic', 'Honda', 2021, 'CARRO', 'Prata', TRUE, 250.00, 8500),
    ('MOT0A01', 'Biz', 'Honda', 2019, 'MOTO', 'Vermelha', TRUE, 80.00, 32000),
    ('DEF4C21', 'Corolla', 'Toyota', 2022, 'CARRO', 'Preto', FALSE, 300.00, 5000),
    ('AGF3F64', 'Sienna', 'Toyota', 2020, 'CARRO', 'Prata', TRUE, 180.00, 28000),
    ('FHT3H57', 'Creta', 'Hyundai', 2021, 'CARRO', 'Branco', TRUE, 220.00, 15000),
    ('LGY4I97', 'Pop 110i', 'Honda', 2019, 'MOTO', 'Azul', TRUE, 70.00, 18000),
    ('RRT3J90', 'Uno', 'Fiat', 2022, 'CARRO', 'Vermelho', FALSE, 120.00, 7000),
    ('HIT3K70', 'Onix', 'Chevrolet', 2020, 'CARRO', 'Cinza', TRUE, 200.00, 22000),
    ('JDT9L02', 'Corolla Cross', 'Toyota', 2023, 'CARRO', 'Preto', FALSE, 350.00, 3000);

-- Populando a tabela de locações (com datas mais realistas)
INSERT INTO locacoes (cliente_id, veiculo_id, data_locacao, data_devolucao_prevista, data_devolucao_real, valor_total, status)
VALUES
    (1, 1, '2023-10-01 09:00:00', '2023-10-05', '2023-10-05', 600.00, 'FINALIZADA'),
    (2, 3, '2023-10-10 14:30:00', '2023-10-15', NULL, 400.00, 'ATIVA'),
    (3, 2, '2023-10-12 10:15:00', '2023-10-14', NULL, 500.00, 'ATIVA'),
    (1, 5, '2023-10-06 11:20:00', '2023-10-09', '2023-10-10', 540.00, 'FINALIZADA'),
    (4, 6, '2023-10-18 16:45:00', '2023-10-19', NULL, 220.00, 'ATIVA'),
    (5, 7, '2023-10-09 08:30:00', '2023-10-12', '2023-10-13', 210.00, 'FINALIZADA'),
    (6, 9, '2023-10-15 13:10:00', '2023-10-16', NULL, 200.00, 'ATIVA'),
    (7, 10, '2023-10-03 15:45:00', '2023-10-05', '2023-10-05', 700.00, 'FINALIZADA'),
    (8, 4, '2023-10-17 10:00:00', '2023-10-19', NULL, 600.00, 'ATIVA'),
    (9, 8, '2023-10-02 12:30:00', '2023-10-15', NULL, 1560.00, 'ATIVA');

-- Populando a tabela de pagamentos (com mais detalhes)
INSERT INTO pagamentos (locacao_id, forma_pagamento, valor_pago, data_pagamento, codigo_transacao)
VALUES
    (1, 'CRÉDITO', 600.00, '2023-10-01 09:30:00', 'PAG123456789'),
    (2, 'PIX', 400.00, '2023-10-10 15:00:00', 'PIX987654321'),
    (3, 'DÉBITO', 500.00, '2023-10-12 10:30:00', 'DEB456123789'),
    (4, 'CRÉDITO', 540.00, '2023-10-06 12:00:00', 'PAG987123654'),
    (5, 'DÉBITO', 220.00, '2023-10-18 17:30:00', 'DEB321654987'),
    (6, 'CRÉDITO', 210.00, '2023-10-09 09:15:00', 'PAG654987321'),
    (7, 'DÉBITO', 200.00, '2023-10-15 14:00:00', 'DEB789321654'),
    (8, 'PIX', 700.00, '2023-10-03 16:30:00', 'PIX321654987'),
    (9, 'CRÉDITO', 600.00, '2023-10-17 11:00:00', 'PAG789456123'),
    (10, 'DINHEIRO', 1560.00, '2023-10-02 13:00:00', 'CAI123789456');

-- Populando a tabela de manutenções (com mais detalhes)
INSERT INTO manutencoes (veiculo_id, data_inicio, data_fim, descricao, custo, tipo, responsavel)
VALUES
    (4, '2023-09-20', '2023-09-25', 'Troca de óleo e revisão geral', 350.00, 'PREVENTIVA', 'Oficina Central'),
    (1, '2023-10-06', '2023-10-07', 'Alinhamento e balanceamento', 200.00, 'PREVENTIVA', 'Mecânica Rápida'),
    (4, '2023-09-10', '2023-09-11', 'Troca de bateria', 650.00, 'CORRETIVA', 'Auto Elétrica'),
    (3, '2023-10-06', '2023-10-07', 'Troca do filtro de ar', 120.00, 'PREVENTIVA', 'Oficina Motos'),
    (2, '2023-09-20', '2023-09-21', 'Troca de óleo e filtros', 280.00, 'PREVENTIVA', 'Mecânica Premium'),
    (8, '2023-10-06', '2023-10-09', 'Reparo na lataria', 450.00, 'FUNILARIA', 'Funilaria Paint'),
    (9, '2023-09-20', '2023-09-21', 'Revisão geral pós-locação', 300.00, 'PREVENTIVA', 'Oficina Central'),
    (2, '2023-10-06', '2023-10-06', 'Limpeza interna completa', 80.00, 'PREVENTIVA', 'Auto Spa'),
    (6, '2023-09-20', '2023-09-21', 'Troca de pneus', 1200.00, 'CORRETIVA', 'Pneus & Rodas'),
    (7, '2023-10-06', '2023-10-06', 'Regulagem de freios', 90.00, 'PREVENTIVA', 'Oficina Motos');

	-- Consultas de exemplo (atualizadas)
-- 1. Veículos disponíveis para locação
SELECT modelo, marca, ano, valor_diaria 
FROM veiculos 
WHERE disponivel = TRUE 
ORDER BY valor_diaria;

-- 2. Locações ativas com detalhes do cliente e veículo
SELECT 
    l.locacao_id,
    c.nome AS cliente,
    v.modelo || ' (' || v.placa || ')' AS veiculo,
    l.data_locacao,
    l.data_devolucao_prevista,
    l.valor_total
FROM locacoes l
JOIN clientes c ON l.cliente_id = c.cliente_id
JOIN veiculos v ON l.veiculo_id = v.veiculo_id
WHERE l.status = 'ATIVA'
ORDER BY l.data_devolucao_prevista;

-- 3. Faturamento total por forma de pagamento
SELECT 
    forma_pagamento,
    SUM(valor_pago) AS total_recebido,
    COUNT(*) AS quantidade_pagamentos
FROM pagamentos
GROUP BY forma_pagamento
ORDER BY total_recebido DESC;

-- 4. Finalizar uma locação
UPDATE locacoes
SET 
    data_devolucao_real = CURRENT_DATE,
    status = 'FINALIZADA'
WHERE locacao_id = 2;

-- Atualizar disponibilidade do veículo
UPDATE veiculos
SET disponivel = TRUE
WHERE veiculo_id = (SELECT veiculo_id FROM locacoes WHERE locacao_id = 2);

-- 5. Relatório de veículos mais locados
SELECT 
    v.modelo,
    v.marca,
    COUNT(l.locacao_id) AS total_locacoes,
    SUM(COALESCE(l.valor_total, 0)) AS faturamento_total
FROM veiculos v
LEFT JOIN locacoes l ON v.veiculo_id = l.veiculo_id
GROUP BY v.modelo, v.marca
ORDER BY total_locacoes DESC;

-- 6. Clientes que mais gastaram
SELECT 
    c.nome,
    c.telefone,
    COUNT(l.locacao_id) AS total_locacoes,
    SUM(COALESCE(l.valor_total, 0)) AS total_gasto
FROM clientes c
LEFT JOIN locacoes l ON c.cliente_id = l.cliente_id
GROUP BY c.nome, c.telefone
ORDER BY total_gasto DESC
LIMIT 5;

-- 7. Histórico de manutenções por veículo
SELECT 
    v.modelo,
    v.placa,
    m.descricao,
    m.data_inicio,
    m.data_fim,
    m.custo
FROM manutencoes m
JOIN veiculos v ON m.veiculo_id = v.veiculo_id
ORDER BY v.modelo, m.data_inicio DESC;
