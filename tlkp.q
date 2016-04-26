/KDB+ Table Lookup Code
\c 20 3000
\p 5000


/Temporary Testing Table
tips_lkp:(7#"*";enlist",") 0: `:tips.csv

tabs:(tables`) where (tables`) like "*_lkp";

/Create Index Tables
it:{[t;x] (enlist x)!enlist ?[t;();();(iasc;x)]}
ct:{xt:string x; eval parse xt,"_index::flip raze it[`",xt,";] each cols `",xt}
ct each tabs;

/
q)t:([]a:`d`c`b`a;b:1 2 3 4)
q)flip raze it[t;] each cols t
a b
---
3 0
2 1
1 2
0 3

q){xt:string x; eval parse xt,"_index::flip raze it[`",xt,";] each cols `",xt} `t
a b
---
3 0
2 1
1 2
0 3
q)t_index
a b
---
3 0
2 1
1 2
0 3

\


/Modify .z.ph
.z.ph:{show -8!x; temp:: x; res:getRes[-8!x]; show res;:res}

/Rest of Code

/Filter Function
likef: {enlist (like;x;y)}

/Get Specific Indices from Table
getInd:{[t;st;len] :?[t;enlist (within;`i;(enlist;st;st+len-1));0b;()]}

/dataf
dataf:{("[\"",ssr[x;",";"\",\""]),"\"]"}

/simplejoiner
sj:{"\"",x,"\":",string y}

/Data Stringer
st:{"[\"",(ssr[x;",";"\",\""]),"\"]"}

/Remove Breaks
rmbr: {ssr[x;"[][]";"_"]}


getQueryTable:{[qurl]
  x:qurl;
  mx:  m where (m:(m where (m:"&" vs .h.uh x) like "[?a-zA-Z]*")) like "*=*";
  mx2: (,/) {d:"=" vs x;:(enlist `$rmbr d 0)! enlist `$d 1} each mx;
  qt:  ([]keyc:key mx2; valc: value mx2);
  qt:  update willsearch:1 from qt where keyc like "*search__value_", not valc like "";
  qt:  update willorder:1 from qt where keyc like "order_*__column_",not valc like "";
  qt:  1!update column: {"I"$ssr[string x;"[a-zA-Z,_]";""]} each keyc from qt;

  qt
  }


getOrderF:{[qt]
  :eval parse (raze "x",string qt[`order_0__dir_][`valc],"[`",colst["I"$string qt[`order_0__column_][`valc]],";]")
  }

createParseTree:{[qt]
  pt:exec {(string x),"*"} each valc,colst[column] from qt where willsearch=1;
  :(,/) (pt`column) (likef)' (pt`valc)
  }

processTable:{[qt]

  t: qt[`table][`valc];
  ind: (`st`len)!"J"$string (qt[`start][`valc];qt[`length][`valc]);
  colst: (0 +til count cols t)!cols t;
  ind: "J"$string (qt[`start][`valc];qt[`length][`valc]);

  parse_tree:$[0~exec sum willsearch from qt;`symbol$();createParseTree[qt]];
  order_function:$[`order_0__column_ in exec keyc from qt;getOrderF[qt];{x}];

  if[not parse_tree=`symbol$();t:?[t;parse_tree;0b;()]];

  /Select Indices
  table:getInd[order_function[t];ind`st;ind`len];
  :table
  }

getTable:{[qt]


  /Step 1: Apply filter

  /Step 2: Check Sort Order
  table:processTable[qt];

  draw: "I"$string qt[`draw][`valc];
  recordsTotal: ?[table;();();(#:;`i)];

  /TEMPORARILY ASSIGNING VALUE OF recordsTotal, should actually have filtered total
  recordsFiltered: recordsTotal;

  td:(`table`qt`recordsTotal`recordsFiltered`draw)!(table;qt;recordsTotal;recordsFiltered;draw);
  :td

  }


createJSON:{[td]

  t:td`table;
  qt:td`qt;

  /Data Functions
  dataheader:"\"data\":[";
  databody:"," sv st each 1_.h.tx.csv t;
  datafooter:"]";
  data: dataheader, databody, datafooter;

  draw: sj["draw";td`draw];
  recordsTotal: sj["recordsTotal"; td`recordsTotal];
  recordsFiltered: sj["recordsFiltered"; td`recordsFiltered];
  callback:string qt[`$"?callback"][`valc];

  returnVal:(callback,"({","," sv (draw;recordsTotal;recordsFiltered;data)),"})";
  :returnVal

  }


getRes:{[x]
  query: -9!x;
  qurl: query 0;
  qt: getQueryTable[qurl];
  td: getTable[qt];
  res: createJSON[td];
  :res
  }


