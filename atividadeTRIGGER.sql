create database lojatestebancobd2;
use lojatestebancobd2;
create table produto(
CodigoProduto int not null primary key,
nome varchar(150),
descriacao varchar(199),
qtde_estoque int
)Engine = InnoDB;

insert into produto values('2', "Pinça de freio", "pinça de freio amg", '7');
select * from produto;

create table cliente(
CodigoCliente int not null primary key,
nome varchar(150),
email varchar(199),
cpf varchar(199)
)Engine = InnoDB;

create table pedido(
CodigoPedido int not null primary key,
dataPedido date,
status varchar(199)
)Engine = InnoDB;

create table itempedido(
CodigoPedido int not null,
CogigoProduto int not null,	
PrecoVenda decimal,
qtde int,
FOREIGN KEY (CodigoPedido) REFERENCES pedido(CodigoPedido),
FOREIGN KEY (CogigoProduto) REFERENCES produto(CodigoProduto) 
)Engine = InnoDB;

create table Funcionario(
CodigoFuncionario int not null primary key,
nome varchar(150),
funcao varchar(150),
cidade varchar(150)
)Engine = InnoDB;

create table Vendedor(
CodigoFuncionario int not null,
FOREIGN KEY (CodigoFuncionario) REFERENCES Funcionario(CodigoFuncionario) 
)Engine = InnoDB;

create table Auditoria(
DataModicacao datetime default current_timestamp,
nomeTabela varchar(200),
historico text
)Engine = InnoDB;

delimiter $
create trigger trg_inserir_produto after insert on produto for each row
begin
	insert into Auditoria values('produtos', concat('Foi inserido o produto de codigo: ', new.CodigoProduto, 'com o preço igual: ', new.produto));
end$
delimiter ;

delimiter $
create trigger trg_inserir_pedido after insert on itempedido for each row
begin
	update produto set qtde_estoque = qtde_estoque - new.qtde
    where CogigoProduto = new.CogigoProduto;
end$
delimiter ;


-- PROFESSOR, EU N FAÇO A MENOR IDEIA DE COMO FAZER ESSA ATIVIDADE, EU TENTEI, MAS NÃO OBTIVE ÊXITO
-- Meu revisor é André Carlos