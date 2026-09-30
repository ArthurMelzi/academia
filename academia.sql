CREATE TABLE alunos (
	id SERIAL PRIMARY KEY,
	nome TEXT NOT NULL,
	email TEXT UNIQUE NOT NULL,
	cpf VARCHAR(11) UNIQUE NOT NULL,
	telefone TEXT NOT NULL,
	data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE planos (
	id SERIAL PRIMARY KEY,
	nome TEXT UNIQUE NOT NULL,
	valor_mensal_base NUMERIC NOT NULL CHECK (valor_mensal_base > 0)
);

CREATE TABLE modalidades (
	id SERIAL PRIMARY KEY,
	plano_id INTEGER REFERENCES planos(id),
	nome TEXT NOT NULL,
	sala TEXT NOT NULL,
	capacidade_maxima INTEGER NOT NULL CHECK (capacidade_maxima > 0),
	disponivel BOOLEAN DEFAULT TRUE
);

CREATE TABLE matriculas (
	id SERIAL PRIMARY KEY,
	aluno_id INTEGER REFERENCES alunos(id),
	data_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	status TEXT DEFAULT 'Ativa' CHECK (status IN ('Ativa', 'Cancelada', 'Trancada'))
);

CREATE TABLE itens_matricula (
	id SERIAL PRIMARY KEY,
	matricula_id INTEGER REFERENCES matriculas(id),
	modalidade_id INTEGER REFERENCES modalidades(id),
	duracao_meses INTEGER NOT NULL CHECK (duracao_meses > 0),
	valor_mensal_aplicado DECIMAL NOT NULL CHECK (valor_mensal_aplicado > 0),
	taxa_adesao DECIMAL NOT NULL DEFAULT 0.00 CHECK (taxa_adesao >= 0)
);

INSERT INTO planos (nome, valor_mensal_base) VALUES
('Mensal Light', 119.90),
('Semestral Fit', 159.90),
('Anual Black', 199.90);

INSERT INTO modalidades (plano_id, nome, sala, capacidade_maxima, disponivel) VALUES
(2, 'Musculação', '01', 20, true),
(3, 'Pilates', '02', 15, false),
(4, 'Crossfit', '03', 30, true);

INSERT INTO alunos (nome, email, cpf, telefone) VALUES
('Carlos Eduardo Souza', 'carlos@gmail.com', 1323981323, '+55 48 99603-1232'),
('Mariana Costa Ribeiro', 'maria@gmail.com', 11267325632, '48 99603-5432'),
('Rodrigo Alves Pereira', 'rodrigo.pereira@gmail.com',12317367121, '48990634321');

INSERT INTO matriculas (aluno_id, status) VALUES 
(1, 'Ativa'), 
(1, 'Ativa'), 
(2, 'Ativa'), 
(3, 'Cancelada');

INSERT INTO itens_matricula (matricula_id, modalidade_id, duracao_meses, valor_mensal_aplicado, taxa_adesao) VALUES 
(1, 1, 6, 234.00, 21.00),
(2, 2, 3, 212.00, 21.00),
(3, 3, 12, 321.00, 32.00),
(4, 1, 1, 324.00, 24.00);

CREATE VIEW vw_custo_aproximado AS
SELECT 
    m.nome AS modalidade, 
    m.sala, 
    p.nome AS plano, 
    ROUND(p.valor_mensal_base * 1.10, 2) AS mensalidade_com_taxa
FROM modalidades m -- m é pra abreviar
JOIN planos p ON m.plano_id = p.id -- p também
ORDER BY mensalidade_com_taxa DESC;

CREATE VIEW vw_matriculas_ativas AS
SELECT 
    a.nome AS aluno, 
    a.cpf, 
    mod.nome AS modalidade, 
    mod.sala, 
    im.duracao_meses, 
    mat.data_inicio
FROM matriculas mat
JOIN alunos a ON mat.aluno_id = a.id
JOIN itens_matricula im ON mat.id = im.matricula_id
JOIN modalidades mod ON im.modalidade_id = mod.id
WHERE mat.status = 'Ativa';

CREATE VIEW vw_alunos_vip AS
SELECT 
    a.nome AS aluno, 
    COUNT(mat.id) AS total_matriculas, 
    SUM((im.valor_mensal_aplicado * im.duracao_meses) + im.taxa_adesao) AS total_investido
FROM alunos a
JOIN matriculas mat ON a.id = mat.aluno_id
JOIN itens_matricula im ON mat.id = im.matricula_id
WHERE mat.status = 'Ativa'
GROUP BY a.id, a.nome
HAVING SUM((im.valor_mensal_aplicado * im.duracao_meses) + im.taxa_adesao) > 1000.00;

SELECT m.*, p.nome AS plano, p.valor_mensal_base
FROM modalidades m
JOIN planos p ON m.plano_id = p.id
WHERE m.capacidade_maxima >= 15 
  AND p.valor_mensal_base > 100.00 
  AND m.disponivel = TRUE;

CREATE VIEW vw_faturamento_plano AS
SELECT 
    p.nome AS plano, 
    SUM((im.valor_mensal_aplicado * im.duracao_meses) + im.taxa_adesao) AS faturamento_total,
    ROUND(AVG(im.duracao_meses), 1) AS media_meses_contratados
FROM itens_matricula im
JOIN matriculas mat ON im.matricula_id = mat.id
JOIN modalidades m ON im.modalidade_id = m.id
JOIN planos p ON m.plano_id = p.id
WHERE mat.status = 'Ativa'
GROUP BY p.nome;
