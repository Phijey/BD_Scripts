
-- exemplos codigo professor 
use sakila;
Create or Replace View Identifica_Clientes_Ativos_Inativos as
select 
   CONCAT(First_Name, ' ', last_name) as cliente, 
   'Ativo' Situacao
from 
   Customer 
where 
   Active = 1
UNION
select 
    CONCAT(First_Name, ' ', last_name) as cliente,
    'Inativo' Situacao
from 
    Customer
where 
   Active = 0;


-- relevantes do código acima: 
-- Create  permite criar o objeto View no banco de dados, tornando-se perene ao longo do tempo. Ou seja, uma vez criada a View, será possível reutilizada em outro momento.
-- Replace permite fazer alterações em uma View criada. Neste caso, recomenda-se que seja usado em conjunto CREATE or REPLACE para facilitar a manutenção do script, caso seja necessário.

-- 1 parte 

-- 1- View para retornar os filmes que foram vistos por clientes inativos cujo país inicie com a letra "A"
create or replace view filmes_clientes_inativos_a as
select film.title, customer.first_name, customer.last_name
from customer
inner join rental on rental.customer_id = customer.customer_id
inner join inventory on inventory.inventory_id = rental.inventory_id
inner join film on film.film_id = inventory.film_id
inner join address on address.address_id = customer.address_id
inner join city on city.city_id = address.city_id
inner join country on country.country_id = city.country_id
where customer.active = 0
and country.country like 'A%';
select * from filmes_clientes_inativos_a;

-- 2- View relacionando filmes, atores e categorias que não estão presentes no estoque
create or replace view filmes_atores_sem_estoque as
select film.title, actor.first_name, actor.last_name, category.name as categoria
from film
inner join film_actor on film.film_id = film_actor.film_id
inner join actor on actor.actor_id = film_actor.actor_id
inner join film_category on film.film_id = film_category.film_id
inner join category on category.category_id = film_category.category_id
where film.film_id not in (select inventory.film_id from inventory);
select * from filmes_atores_sem_estoque;


-- 3) View unificando duas consultas sobre filmes alugados em maio de 2005 e filmes com duração menor que 5 e tamanho maior que 100
create or replace view filmes_unificados as
select film.title, category.name as categoria
from rental
inner join inventory on rental.inventory_id = inventory.inventory_id
inner join film on inventory.film_id = film.film_id
inner join film_category on film.film_id = film_category.film_id
inner join category on film_category.category_id = category.category_id
where rental.rental_date between '2005-05-01' and '2005-05-31'
and category.name in ('Action', 'Drama', 'Documentary')
union
select film.title, category.name as categoria
from film
inner join film_category on film.film_id = film_category.film_id
inner join category on film_category.category_id = category.category_id
where film.rental_duration < 5 and film.length > 100
and category.name in ('Animation', 'Comedy', 'Horror');
select * from filmes_unificados;


-- exemplo 2   

CREATE TABLE CLIENTES_ATIVOS
Select 
   Concat(First_name, ‘ ’, Last_name) as cliente,
   City.City as cidade, 
   Country.Country as pais
From 
  Customer
      Inner Join Address using (Address_id)
      Inner Join City using (City_id)
      Inner Join Country using (Country_id)
Where
   Active = 1;

select * from clientes_ativos;

-- 4) Tabela com total de pagamentos por loja
create table total_pagamentos_por_loja as
select store.store_id, sum(payment.amount) as total_pagamento
from payment
inner join rental on payment.rental_id = rental.rental_id
inner join inventory on rental.inventory_id = inventory.inventory_id
inner join store on inventory.store_id = store.store_id
group by store.store_id;
select * from total_pagamentos_por_loja;

-- 5) Tabela com média, total, quantidade, valor máximo e valor mínimo de pagamentos por loja
create table estatisticas_pagamento_por_loja as
select store.store_id, avg(payment.amount) as media_pagamento, sum(payment.amount) as total_pagamento, count(payment.payment_id) as qtd_pagamentos,
max(payment.amount) as max_pagamento, min(payment.amount) as min_pagamento
from payment
inner join rental on payment.rental_id = rental.rental_id
inner join inventory on rental.inventory_id = inventory.inventory_id
inner join store on inventory.store_id = store.store_id
group by store.store_id;
select * from estatisticas_pagamento_por_loja;

-- corrigir 

-- 6) Tabela com o total de pagamentos executados entre março e setembro de 2005 por clientes inativos
create table total_pagamentos_inativos_marco_set as
select sum(payment.amount) as total_pagamentos
from payment
inner join rental on payment.rental_id = rental.rental_id
inner join customer on rental.customer_id = customer.customer_id
where customer.active = 0
and payment.payment_date between '2005-03-01' and '2005-09-30';
select * from total_pagamentos_inativos_marco_set; 

-- 7) Tabela com filme, ator e categoria
create table filme_ator_categoria as
select film.title, film.film_id, concat(actor.first_name, ' ', actor.last_name) as ator, actor.actor_id, category.name as categoria, category.category_id
from film
inner join film_actor on film.film_id = film_actor.film_id
inner join actor on actor.actor_id = film_actor.actor_id
inner join film_category on film.film_id = film_category.film_id
inner join category on film_category.category_id = category.category_id;
select * from filme_ator_categoria;

-- 8) View Estoque_Aluguel
create or replace view estoque_aluguel as
select inventory.inventory_id, rental.rental_id, rental.customer_id, categoria.categoria
from filme_ator_categoria as categoria
inner join inventory on inventory.film_id = categoria.film_id
inner join rental on rental.inventory_id = inventory.inventory_id;
select * from estoque_aluguel;

-- 9) View Pagamento_Categoria
create or replace view pagamento_categoria as
select categoria.categoria, sum(payment.amount) as total_pagamentos
from estoque_aluguel as categoria
inner join rental on estoque_aluguel.rental_id = rental.rental_id
inner join payment on payment.rental_id = rental.rental_id
group by categoria.categoria;
select * from pagamento_categoria;

-- 10) View Clientes_Categoria
create or replace view clientes_categoria as
select categoria.categoria, count(distinct clientes.cliente) as qtd_clientes
from estoque_aluguel as categoria
inner join clientes_ativos as clientes on estoque_aluguel.customer_id = clientes.customer_id
group by categoria.categoria;
select * from clientes_categoria;

-- parte feita por iago dias e rafael matheus.

-- PARTE 2
-- PROCEDURE
use classicmodels;
 -- 11) 
 DELIMITER $$

CREATE PROCEDURE TodosClientes()
BEGIN
    SELECT * FROM CUSTOMERS;
END $$

DELIMITER ;
CALL TodosClientes();

-- 12) 
DELIMITER $$

CREATE PROCEDURE VendasPorCidadeAno(
    IN p_city VARCHAR(50),
    IN p_year INT
)
BEGIN
    SELECT 
        P.productName,
        SUM(OD.quantityOrdered) AS totalSold
    FROM 
        CUSTOMERS C
    JOIN 
        ORDERS O ON C.customerNumber = O.customerNumber
    JOIN 
        ORDERDETAILS OD ON O.orderNumber = OD.orderNumber
    JOIN 
        PRODUCTS P ON OD.productCode = P.productCode
    JOIN 
        OFFICES  OFC ON C.salesRepEmployeeNumber = OFC.officeCode
    WHERE 
        OFC.city = p_city AND YEAR(O.orderDate) = p_year
    GROUP BY 
        P.productName
    ORDER BY 
        totalSold DESC;
END $$

DELIMITER ;
CALL VendasPorCidadeAno('Boston', 2004);

-- 13)

DELIMITER $$
select * from offices;
CREATE PROCEDURE RelacaoClienteEscritorio()
BEGIN
    SELECT 
        OFC.officeCode,
        OFC.city,
        C.customerNumber,
        C.customerName
    FROM 
        OFFICES OFC
    JOIN 
        CUSTOMERS C ON OFC.officeCode = C.salesRepEmployeeNumber
    ORDER BY 
        OFC.officeCode, C.customerName;
END $$

DELIMITER ;
CALL RelacaoClienteEscritorio();
-- professor, o código executa, mas n retorna valores, talvez eu n tenha entendido o pedido da questão.

-- 14)
DELIMITER $$

CREATE PROCEDURE TotalVendasAno(
    IN p_ano INT
)
BEGIN
    SELECT 
    YEAR(O.orderDate), 
        SUM(OD.quantityOrdered * P.buyPrice) AS totalVendas
    FROM 
        ORDERS O
    JOIN 
        ORDERDETAILS OD ON O.orderNumber = OD.orderNumber
    JOIN 
        PRODUCTS P ON OD.productCode = P.productCode
    WHERE 
        YEAR(O.orderDate) = p_ano;
END $$

DELIMITER ;
CALL GetTotalSalesByYear(2004);

-- 15)
DELIMITER $$

CREATE PROCEDURE ComparacaoProdutos(
    IN p_ano INT
)
BEGIN
    DECLARE v_max_quantity_product VARCHAR(255);
    DECLARE v_max_quantity INT;
    DECLARE v_max_total_product VARCHAR(255);
    DECLARE v_max_total DECIMAL(10, 2);

    -- Criar uma tabela temporária para armazenar os 10 produtos mais vendidos
    CREATE TEMPORARY TABLE MaioresProdutos AS
    SELECT 
        P.productName,
        SUM(OD.quantityOrdered) AS QtdTotal,
        SUM(OD.quantityOrdered * OD.priceEach) AS TotalValorVenda
    FROM 
        ORDERS O
    JOIN 
        ORDERDETAILS OD ON O.orderNumber = OD.orderNumber
    JOIN 
        PRODUCTS P ON OD.productCode = P.productCode
    WHERE 
        YEAR(O.orderDate) = p_ano
    GROUP BY 
        P.productName
    ORDER BY 
        QtdTotal DESC
    LIMIT 10;

    -- Identificar o produto com maior quantidade vendida
    SELECT 
        productName, QtdTotal
    INTO 
        v_max_quantity_product, v_max_quantity
    FROM 
        MaioresProdutos
    ORDER BY 
        QtdTotal DESC
    LIMIT 1;

    -- Identificar o produto com maior total vendido
    SELECT 
        productName, TotalValorVenda
    INTO 
        v_max_total_product, v_max_total
    FROM 
        MaioresProdutos
    ORDER BY 
        TotalValorVenda DESC
    LIMIT 1;

    -- Comparar os produtos e retornar a mensagem
    IF v_max_quantity_product = v_max_total_product THEN
        SELECT 'Produto Acima das Expectativas' AS ResultMessage;
    ELSE
        SELECT 'Produtos diferentes' AS ResultMessage;
    END IF;

    -- Limpar a tabela temporária
    DROP TEMPORARY TABLE TopProducts;
END $$

DELIMITER ;
CALL ComparacaoProdutos('2004');
-- Professor, tive q usar o chat para me ajudar, dei conta sozinho não.

-- 16)
CREATE TABLE Vendedor_Avaliacao (
    Vendedor VARCHAR(100),
    Avaliacao VARCHAR(100)
);

CREATE VIEW Vendedores_Clientes AS
SELECT IFNULL(COUNT(CUSTOMERNUMBER), 0) AS QTDECLIENTE,
       CONCAT(LASTNAME, ' ', FIRSTNAME) AS VENDEDOR
  FROM EMPLOYEES 
  INNER JOIN OFFICES USING (officeCode)
  LEFT JOIN CUSTOMERS ON (salesRepEmployeeNumber = employeeNumber)
  WHERE JOBTITLE = 'SALES REP'
  GROUP BY VENDEDOR 
  ORDER BY QTDECLIENTE;
  
DELIMITER $

CREATE PROCEDURE AvaliarVendedores()
BEGIN
DECLARE done BOOLEAN DEFAULT FALSE;
DECLARE v_qtdClientes INT;
DECLARE v_vendedor VARCHAR(100);    

DECLARE cursorVendedores CURSOR FOR
        SELECT QTDECLIENTE, VENDEDOR
        FROM Vendedores_Clientes;
    
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cursorVendedores;
    
    leitura_loop: LOOP
        FETCH cursorVendedores INTO v_qtdClientes, v_vendedor;
        
        IF done THEN
            LEAVE leitura_loop;
        END IF;
        
        IF v_qtdClientes > 8 THEN
            INSERT INTO Vendedor_Avaliacao (Vendedor, Avaliacao)
            VALUES (v_vendedor, 'Você executou um excelente trabalho');
        
        ELSEIF v_qtdClientes BETWEEN 6 AND 8 THEN
            INSERT INTO Vendedor_Avaliacao (Vendedor, Avaliacao)
            VALUES (v_vendedor, 'Bom trabalho, mas pode melhorar');
        
        ELSEIF v_qtdClientes BETWEEN 1 AND 5 THEN
            INSERT INTO Vendedor_Avaliacao (Vendedor, Avaliacao)
            VALUES (v_vendedor, 'Acreditamos no seu potencial, precisa de apoio?');
        
        ELSE
            INSERT INTO Vendedor_Avaliacao (Vendedor, Avaliacao)
            VALUES (v_vendedor, 'Passar no RH');
        END IF;
    END LOOP;
    
    CLOSE cursorVendedores;
END $
DELIMITER ;
CALL AvaliarVendedores();
-- Feito por Pedro José

/*questao 17)*/
DELIMITER $

CREATE PROCEDURE VerificarStatusAluno (IN Matricula INT)
BEGIN
    DECLARE NotaPI DECIMAL(5, 2); 
    DECLARE NotaPR DECIMAL(5, 2); 
    DECLARE NotaPF DECIMAL(5, 2); 
    DECLARE TotalFaltas INT; 
    DECLARE FaltasPossiveis INT; 
    DECLARE SomatorioNotas DECIMAL(5, 2); 
    DECLARE PercentualFaltas DECIMAL(5, 2);
    DECLARE StatusAluno VARCHAR(50);

    -- Buscar os dados do aluno na tabela DadosAluno
    SELECT Nota_P.I, Nota_PR, Nota_PF, Total_Faltas, Faltas_Possiveis
    INTO NotaPI, NotaPR, NotaPF, TotalFaltas, FaltasPossiveis
    FROM DadosAluno
    WHERE MatriculaAluno = Matricula;

    -- Calcular o somatório das notas
    SET SomatorioNotas = NotaPI + NotaPR + NotaPF;

    -- Calcular o percentual de faltas
    SET PercentualFaltas = (TotalFaltas / FaltasPossiveis) * 100;

    -- Determinar o status do aluno com base nas condições fornecidas
    IF SomatorioNotas >= 60 AND PercentualFaltas <= 25 THEN
        SET StatusAluno = 'Aprovado';
    ELSEIF SomatorioNotas >= 45 AND SomatorioNotas < 60 AND PercentualFaltas <= 25 THEN
        SET StatusAluno = 'Recuperação';
    ELSEIF SomatorioNotas < 45 THEN
        SET StatusAluno = 'Reprovado';
    ELSEIF PercentualFaltas > 25 AND PercentualFaltas <= 40 AND SomatorioNotas >= 90 THEN
        SET StatusAluno = 'Aprovado';
    ELSE
        SET StatusAluno = 'Reprovado';
    END IF;

    -- Retornar o status do aluno
    SELECT Matricula AS MatriculaAluno, StatusAluno AS StatusAluno;
END $

DELIMITER ;
-- Professor, nessa questão 17, eu teria que criar uma tabela adicional, não?

/*questao 18)*/
DELIMITER $

CREATE PROCEDURE GerenciarBolasNaSacola(
    IN p_QuantidadeBolas INT,
    IN p_CapacidadeTotal INT,
    INOUT p_QuantidadeExistente INT
)
BEGIN
    -- Verifica se a quantidade a ser inserida é inválida
    IF p_QuantidadeBolas > 0 AND p_QuantidadeBolas < 2 THEN
        SELECT '** O VALOR INSERIDO É INVALIDO. POR FAVOR, TENTE NOVAMENTE! **' AS Mensagem;
    
    -- Verifica se o total após a inserção excede a capacidade da sacola
    ELSEIF (p_QuantidadeExistente + p_QuantidadeBolas) > p_CapacidadeTotal THEN
        SELECT '** VOCÊ ULTRAPASSOU A CAPACIDADE DA SACOLA. POR FAVOR, INSIRA OUTRO VALOR. **' AS Mensagem;

    -- Caso a quantidade de bolas seja positiva e não ultrapasse a capacidade
    ELSEIF p_QuantidadeBolas > 0 THEN
        SET p_QuantidadeExistente = p_QuantidadeExistente + p_QuantidadeBolas;
        SELECT CONCAT('A quantidade de bolas agora é: ', p_QuantidadeExistente) AS Mensagem;
    
    -- Caso a quantidade de bolas seja negativa, para remoção
    ELSEIF p_QuantidadeBolas < 0 THEN
        SET p_QuantidadeExistente = p_QuantidadeExistente + p_QuantidadeBolas;
        
        -- Verifica se a sacola está vazia ou a quantidade é zero ou negativa após a remoção
        IF p_QuantidadeExistente <= 0 THEN
            SET p_QuantidadeExistente = 0;
            SELECT '** TODAS AS BOLAS FORAM REMOVIDAS DA SACOLA. **' AS Mensagem;
        ELSE
            SELECT CONCAT('A quantidade de bolas após remoção é: ', p_QuantidadeExistente) AS Mensagem;
        END IF;
    
    -- Caso contrário, exibir mensagem de erro genérica
    ELSE
        SELECT '** OCORREU UM ERRO. POR FAVOR, VERIFIQUE OS VALORES INSERIDOS. **' AS Mensagem;
    END IF;
END $

DELIMITER ;
SET QuantidadeExistente = 5;
CALL GerenciarBolasNaSacola(3, 10, QuantidadeExistente);

/*questao 19)*/
DELIMITER $

CREATE PROCEDURE VerificarTriangulo (
    IN p_LadoA INT,
    IN p_LadoB INT,
    IN p_LadoC INT
)
BEGIN
    DECLARE CategoriaTriangulo VARCHAR(50);

    -- Verificar se os lados podem formar um triângulo
    IF (p_LadoA + p_LadoB > p_LadoC) AND 
       (p_LadoA + p_LadoC > p_LadoB) AND 
       (p_LadoB + p_LadoC > p_LadoA) THEN

        -- Verificar o tipo de triângulo
        IF p_LadoA = p_LadoB AND p_LadoB = p_LadoC THEN
            SET CategoriaTriangulo = 'Triângulo Equilátero';
        ELSEIF p_LadoA = p_LadoB OR p_LadoA = p_LadoC OR p_LadoB = p_LadoC THEN
            SET CategoriaTriangulo = 'Triângulo Isósceles';
        ELSE
            SET CategoriaTriangulo = 'Triângulo Escaleno';
        END IF;

        -- Exibir o tipo de triângulo
        SELECT CategoriaTriangulo AS Resultado;
    ELSE
        -- Caso não forme um triângulo
        SELECT 'Não é um triângulo' AS Resultado;
    END IF;
END $

DELIMITER ;
CALL VerificarTriangulo(5, 5, 8);

/*questao 20)*/
CREATE TABLE Taxa_Crescimento_De_Venda (
    Id_Vendedor INT,
    Nome_Vendedor VARCHAR(100),
    Ano INT,
    Valor_Janeiro_base FLOAT,
    Taxa_Fevereiro VARCHAR(5),
    Taxa_Marco VARCHAR(5),
    Taxa_Abril VARCHAR(5),
    Taxa_Maio VARCHAR(5),
    Taxa_Junho VARCHAR(5),
    PRIMARY KEY (Id_Vendedor, Ano, Valor_Janeiro_base)
);

CREATE VIEW Vendas_Mensais_View AS
SELECT 
    Id_Vendedor,
    Nome_Vendedor,
    Ano,
    'Janeiro' AS Mes_Venda,
    Valor_Janeiro_base AS Valor_Mensal
FROM Taxa_Crescimento_De_Venda

UNION ALL

SELECT 
    Id_Vendedor,
    Nome_Vendedor,
    Ano,
    'Fevereiro' AS Mes_Venda,
    Valor_Janeiro_base * (1 + (CAST(REPLACE(Taxa_Fevereiro, '%', '') AS FLOAT) / 100)) AS Valor_Mensal
FROM Taxa_Crescimento_De_Venda

UNION ALL

SELECT 
    Id_Vendedor,
    Nome_Vendedor,
    Ano,
    'Março' AS Mes_Venda,
    Valor_Janeiro_base * (1 + (CAST(REPLACE(Taxa_Marco, '%', '') AS FLOAT) / 100)) AS Valor_Mensal
FROM Taxa_Crescimento_De_Venda

-- Repetir o mesmo padrão para os outros meses até Junho...

ORDER BY Id_Vendedor, Ano, Mes_Venda;

DELIMITER $

CREATE PROCEDURE GerenciarCrescimentoVendas(
    IN p_Id_Vendedor INT,
    IN p_Nome_Vendedor VARCHAR(100),
    IN p_Ano INT,
    IN p_Valor_Janeiro FLOAT,
    IN p_Valor_Fevereiro FLOAT,
    IN p_Valor_Marco FLOAT,
    IN p_Valor_Abril FLOAT,
    IN p_Valor_Maio FLOAT,
    IN p_Valor_Junho FLOAT
)
BEGIN
    DECLARE taxa FLOAT;
    DECLARE valor_anterior FLOAT;
    DECLARE valor_atual FLOAT;
    
    -- Verificar se o vendedor já existe na tabela para o mês de janeiro
    IF NOT EXISTS (SELECT * FROM Taxa_Crescimento_De_Venda 
                   WHERE Id_Vendedor = p_Id_Vendedor AND Ano = p_Ano) THEN
        -- Inserir novo registro para o mês de Janeiro
        INSERT INTO Taxa_Crescimento_De_Venda (Id_Vendedor, Nome_Vendedor, Ano, Valor_Janeiro_base)
        VALUES (p_Id_Vendedor, p_Nome_Vendedor, p_Ano, p_Valor_Janeiro);
    END IF;
    
    -- Atualizar taxas de crescimento mês a mês (começando em fevereiro)
    SET valor_anterior = p_Valor_Janeiro;
    
    -- Verificar e atualizar Fevereiro
    SET valor_atual = p_Valor_Fevereiro;
    IF valor_atual > valor_anterior THEN
        SET taxa = ((valor_atual / valor_anterior) - 1) * 100;
    ELSE
        SET taxa = ((valor_anterior / valor_atual) - 1) * -100;
    END IF;
    UPDATE Taxa_Crescimento_De_Venda
    SET Taxa_Fevereiro = CONCAT(ROUND(taxa, 2), '%')
    WHERE Id_Vendedor = p_Id_Vendedor AND Ano = p_Ano;

    -- Repetir a lógica para Março, Abril, Maio e Junho
    SET valor_anterior = valor_atual; -- Atualiza o valor anterior para o próximo cálculo

    -- Exemplo para Março
    SET valor_atual = p_Valor_Marco;
    IF valor_atual > valor_anterior THEN
        SET taxa = ((valor_atual / valor_anterior) - 1) * 100;
    ELSE
        SET taxa = ((valor_anterior / valor_atual) - 1) * -100;
    END IF;
    UPDATE Taxa_Crescimento_De_Venda
    SET Taxa_Marco = CONCAT(ROUND(taxa, 2), '%')
    WHERE Id_Vendedor = p_Id_Vendedor AND Ano = p_Ano;

    -- Repita a mesma lógica para Abril, Maio e Junho...

END $

DELIMITER ;
CALL GerenciarCrescimentoVendas(
    222, 
    'Prof.BD', 
    2003, 
    9000.00, 
    10000.00, 
    8500.00, 
    9500.00, 
    9700.00, 
    11000.00
);
SELECT * FROM Taxa_Crescimento_De_Venda;

/*questao 21)*/
CREATE TABLE Pais_Cidade (
    NomePais VARCHAR(100),
    CodePais CHAR(3),
    Continente VARCHAR(50),
    CidadesExiste TEXT,
    Territorio DECIMAL(10, 2),
    Populacao INT,
    SituacaoDensidade VARCHAR(100),
    IdomasFalados TEXT
);
CREATE TABLE Log_Pais_Cidade (
    Id INT PRIMARY KEY,
    Descricao TEXT,
    Data TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE VIEW Pais_Cidade_Idioma AS
SELECT 
    p.NomePais,
    p.CodePais,
    p.Territorio,
    p.Populacao,
    GROUP_CONCAT(l.Language) AS ListaIdomas
FROM 
    Pais_Cidade p
JOIN 
    CountryLanguage l ON p.CodePais = l.CountryCode
GROUP BY 
    p.NomePais, p.CodePais, p.Territorio, p.Populacao;
    CREATE VIEW Pais_Cidade_Idioma AS
SELECT 
    p.NomePais,
    p.CodePais,
    p.Territorio,
    p.Populacao,
    GROUP_CONCAT(l.Language) AS ListaIdomas
FROM 
    Pais_Cidade p
JOIN 
    CountryLanguage l ON p.CodePais = l.CountryCode
GROUP BY 
    p.NomePais, p.CodePais, p.Territorio, p.Populacao;
    CREATE FUNCTION calcular_densidade(Territorio DECIMAL(10, 2), Populacao INT)
RETURNS VARCHAR(100)
BEGIN
    DECLARE densidade DECIMAL(10, 2);
    SET densidade = Populacao / Territorio;
    IF densidade >= 90 THEN
        RETURN 'Populoso';
    ELSEIF densidade BETWEEN 20 AND 90 THEN
        RETURN 'Povoado';
    ELSE
        RETURN 'Incentiva imigração';
    END IF;
END;
CREATE TRIGGER atualizar_log_pais_cidade
AFTER UPDATE ON Pais_Cidade
FOR EACH ROW
BEGIN
    INSERT INTO Log_Pais_Cidade (Descricao)
    VALUES (CONCAT('Atualizado o país ', NEW.NomePais, ' com a densidade ', calcular_densidade(NEW.Territorio, NEW.Populacao)));
END;
CREATE PROCEDURE inserir_dados_pais_cidade()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE NomePais VARCHAR(100);
    DECLARE CodePais CHAR(3);
    DECLARE Territorio DECIMAL(10, 2);
    DECLARE Populacao INT;
    DECLARE ListaIdomas TEXT;
    DECLARE cur CURSOR FOR SELECT * FROM Pais_Cidade_Idioma;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO NomePais, CodePais, Territorio, Populacao, ListaIdomas;
        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO Pais_Cidade (NomePais, CodePais, Territorio, Populacao, IdomasFalados, SituacaoDensidade)
        VALUES (NomePais, CodePais, Territorio, Populacao, ListaIdomas, calcular_densidade(Territorio, Populacao));
    END LOOP;

    CLOSE cur;
END;
    
/*questao 22)*/

CREATE TABLE Empregado_Cliente_Pagamento (
    CodigoEmpregado INT,
    Qtde_Cliente INT,
    TotalPagamento DECIMAL(10, 2),
    NomeEmpregado VARCHAR(100),
    Escritorio VARCHAR(50) DEFAULT '',
    SituacaoEscritorio VARCHAR(100) DEFAULT '',
    PRIMARY KEY (CodigoEmpregado)
);

CREATE TABLE Log_Empregado_Cliente_Pagamento (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Descricao VARCHAR(255),
    Data TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE VIEW Empregado_Cliente_Pagamento_View AS
SELECT 
    e.EmployeeNumber AS CodigoEmpregado,
    COUNT(c.CustomerNumber) AS Qtde_Cliente,
    SUM(p.Amount) AS TotalPagamento,
    CONCAT(e.FirstName, ' ', e.LastName) AS NomeEmpregado,
    o.City AS CidadeEscritorio
FROM 
    employees e
LEFT JOIN 
    customers c ON e.EmployeeNumber = c.SalesRepEmployeeNumber
LEFT JOIN 
    payments p ON c.CustomerNumber = p.CustomerNumber
LEFT JOIN 
    offices o ON e.OfficeCode = o.OfficeCode
GROUP BY 
    e.EmployeeNumber, o.City;


DELIMITER $

CREATE FUNCTION CalcularSituacaoEscritorio (
    CidadeEscritorio VARCHAR(50),
    TotalPagamento DECIMAL(10, 2)
) RETURNS VARCHAR(100)
BEGIN
    IF CidadeEscritorio = 'Paris' AND TotalPagamento > 900000 THEN
        RETURN 'Escritório superou expectativas - Comemoração';
    ELSEIF TotalPagamento > 700000 THEN
        RETURN 'Excelente trabalho equipe';
    ELSE
        RETURN 'Bom trabalho, mas vamos melhorar';
    END IF;
END $

DELIMITER ;


DELIMITER $

CREATE TRIGGER Log_Update_Empregado_Cliente_Pagamento
AFTER UPDATE ON Empregado_Cliente_Pagamento
FOR EACH ROW
BEGIN
    DECLARE descricao VARCHAR(255);
    SET descricao = CONCAT('Produto: ', NEW.NomeEmpregado, ', Valor de Compra: ', NEW.TotalPagamento);
    INSERT INTO Log_Empregado_Cliente_Pagamento (Descricao) VALUES (descricao);
END $

DELIMITER ;

DELIMITER $

CREATE PROCEDURE InserirDadosEmpregadoClientePagamento()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_CodigoEmpregado INT;
    DECLARE v_Qtde_Cliente INT;
    DECLARE v_TotalPagamento DECIMAL(10, 2);
    DECLARE v_NomeEmpregado VARCHAR(100);
    DECLARE v_CidadeEscritorio VARCHAR(50);
    DECLARE v_SituacaoEscritorio VARCHAR(100);

    DECLARE emp_cursor CURSOR FOR 
        SELECT CodigoEmpregado, Qtde_Cliente, TotalPagamento, NomeEmpregado, CidadeEscritorio
        FROM Empregado_Cliente_Pagamento_View;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN emp_cursor;

    read_loop: LOOP
        FETCH emp_cursor INTO v_CodigoEmpregado, v_Qtde_Cliente, v_TotalPagamento, v_NomeEmpregado, v_CidadeEscritorio;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SET v_SituacaoEscritorio = CalcularSituacaoEscritorio(v_CidadeEscritorio, v_TotalPagamento);

        INSERT INTO Empregado_Cliente_Pagamento (CodigoEmpregado, Qtde_Cliente, TotalPagamento, NomeEmpregado, Escritorio, SituacaoEscritorio)
        VALUES (v_CodigoEmpregado, v_Qtde_Cliente, v_TotalPagamento, v_NomeEmpregado, v_CidadeEscritorio, v_SituacaoEscritorio);
    END LOOP;

    CLOSE emp_cursor;
END $

DELIMITER ;
CALL InserirDadosEmpregadoClientePagamento();
SELECT * FROM Empregado_Cliente_Pagamento;
--
-- Feito por André Carlos
--















