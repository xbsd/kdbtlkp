/KDB+ Table Lookup Code
\c 20 3000
\p 5000


/Temporary Testing Table
tips_lkp:("FFSSSSI";enlist",") 0: `:tips.csv
/p_lkp:1000000#select total_bill, day from tips_lkp
/z_lkp:3000000?tips_lkp
maj_lkp:("IISJJSHHJJ";enlist ",") 0: `:majestic_million.csv

/Index Suffix
ISUFFIX:"_index";

tabs: (tables`) where (tables`) like "*_lkp";
/tabs:`Product`Prescriber;
tdict: tabs!(`$(string tabs) ,\: ISUFFIX);

/Create Index Tables
it:{[t;x] (enlist x)!enlist ?[t;();();(rank;x)]}
ct:{xt:string x; eval parse xt, ISUFFIX,"::flip raze it[`",xt,";] peach cols `",xt}
ct each tabs;

/String Tables
strt:{[ta] ta:0!?[ta;();0b;()]; ct: cols ta; nstc: exec c from (0!meta ta) where not t in "Cc"; stc:ct except nstc; brk:1; if[0~count nstc;res:?[ta;();0b;()];brk:0];if[0~count stc;res:string ?[ta;();0b;()];brk:0];if[brk=1;res:(string ?[ta;();0b;nstc!nstc]),'?[ta;();0b;stc!stc]];:res}

{x set strt x} each tabs;


/

zz:exec i from tips_lkp where total_bill like "10*"

- Use this -- @[tips_lkp;zz iasc @[tips_lkp_index`total_bill;zz]]

AND FOR SELECTING ONLY SPECIFIC COLUMNS --

q)\t @[tips_lkp;@[zz iasc @[tips_lkp_index`total_bill;zz];10 +til 10]] /Rows 10 - 20
95


zz:exec i from tips_lkp where total_bill like "10*"
\t @[tips_lkp;@[zz iasc @[tips_lkp_index`total_bill;zz];10 +til 10]]
28


q)@[tips_lkp;@[zz iasc @[tips_lkp_index`total_bill;zz];10 +til 10]]
total_bill tip
-----------------
"10.07"    "1.83"
"10.07"    "1.25"
"10.07"    "1.83"
"10.07"    "1.25"
"10.07"    "1.83"
"10.07"    "1.25"
"10.07"    "1.83"
"10.07"    "1.25"
"10.07"    "1.83"
"10.07"    "1.25"
q)\t `total_bill xasc tips_lkp
19701



FOR DESCENDING --

q)@[tips_lkp;@[zz idesc @[tips_lkp_index`total_bill;zz];10 +til 10]] /Use idesc

total_bill tip    sex    smoker day   time     size
---------------------------------------------------
"9.94"     "1.56" "Male" "No"   "Sun" "Dinner" ,"2"
"9.94"     "1.56" "Male" "No"   "Sun" "Dinner" ,"2"
"9.94"     "1.56" "Male" "No"   "Sun" "Dinner" ,"2"


/@[@[tips_lkp;zz];iasc @[tips_lkp_index`total_bill;zz]]

OR

zz:exec i from tips_lkp where tip like "2*"
@[@[tips_lkp;zz];iasc @[tips_lkp_index`tip;zz]]



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

getPI:{[t;qt;colst]
  pt:exec {(string x),"*"} each valc,colst[column] from qt where willsearch=1;
  pt:$[count pt`valc;(,/) (pt`column) (likef)' (pt`valc);`symbol$()];
  :?[t;pt;();`i]
  }

getOI:{[t;qt;PI;tdict;ind;colst]
  inds: (ind`st) +til (ind`len);
  if[not `order_0__column_ in exec keyc from qt;:PI inds];
  of:$[`asc~qt[`order_0__dir_][`valc];iasc;idesc];
  col: colst "I"$string qt[`order_0__column_][`valc];
  :@[PI of @[?[tdict[t];();();col];PI];inds];
  }



processTable:{[qt]

  t: qt[`table][`valc];
  ind: (`st`len)!"J"$string (qt[`start][`valc];qt[`length][`valc]);
  colst: (0 +til count cols t)!cols t;

  PI: getPI[t;qt;colst]; /Parsed I Values
  table:$[0~count PI;0#?[t;();0b;()];@[t;getOI[t;qt;PI;tdict;ind;colst]]];
 
  :(`table`recordsFiltered)!(table;count PI)
  }

getTable:{[qt]

  t: qt[`table][`valc];  
  proct: processTable[qt];

  table: proct`table;
  recordsFiltered: proct`recordsFiltered;
  recordsTotal: ?[t;();();(#:;`i)];
  draw: "I"$string qt[`draw][`valc];

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

