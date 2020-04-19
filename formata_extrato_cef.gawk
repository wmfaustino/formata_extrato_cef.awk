#!/bin/bash
awk '

BEGIN{
  FS=";";
  OFS=",";
}

NR > 1 { # Despreza o header

  ###### Tira as aspas de todos os campos, exceto o "Histórico"
  {
    for(i=1; i<=NF; i++)
      if($i!=$4){ gsub(/"/,"",$i); }
  }

  ###### Separa a string em agência operação e contaCorrente
  {
    gsub(" ", "", $1); 
    split($1,arr , "/");
  
    agencia =  arr[1];
    operacao = arr[2];
    contaCorrente = arr[3];
  }

  ###### Transforma o número em data padrão yyyy-mm-dd
  {
    ano = substr($2,1,4);
    mes = substr($2,5,2); 
    dia = substr($2,7,2);
    
    data = ano"-"mes"-"dia;
  }

  ###### Altera a forma de apresentação do valor
  {
    if($6 == "D"){$5*=-1}; # Deixa o valor negativo se for débito
    $6="";                 # Deleta a coluna Deb_Cred
  }

  ###### Salva o extrato processado em um arquivo nomeado de acordo com o tipo de conta corrente
  {
    extratoProcessado = agencia "," operacao "," contaCorrente "," data "," $3 "," $4 "," $5;
    
    switch (operacao) {
        case "003":
            outputFile = "extrato_003.gawk.csv"
            break
        case "043":
            outputFile = "extrato_043.gawk.csv"
            break
        default:
            print "Extrato não identificado"
    }
  # print extratoProcessado               # retorna o extrato ao stdout
    print extratoProcessado > outputFile; # retorna o novo extrato ao novo arquivo
  }

}' # $HOME/Downloads/003.txt # pode-se colocar o input aqui. Por padrão, virá no shell através do prompt
