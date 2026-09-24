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

