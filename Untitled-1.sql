Create Table Film (
	FilmId INTEGER PRIMARY KEY NOT NULL,
  	Name varchar(40),
  	Jahr INTEGER,
  	Kosten INTEGER,
  	Regisseur INTEGER REFERENCES Regisseur(RegisseurId) ON DELETE SET NULL ON UPDATE SET NULL ,
  	Genre varchar(40) DEFAULT 'NA' 
);

Create Table Regisseur (
	RegisseurId varchar(40) PRIMARY KEY,
  	Name varchar(40),
  	Age INTEGER
);
 
INSERT INTO Film (FilmId,Name,Jahr,Kosten,Regisseur,Genre)
VALUES (1,'Ghostbusters',1983,150000,1,'Fantasy');

INSERT INTO Regisseur (RegisseurId, Name, Age)
VALUES (1,'Romero',33);

SELECT* FROM Film


