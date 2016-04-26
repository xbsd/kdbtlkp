/KDB+ Table Lookup Code
\c 20 3000

/Modify .z.ph
.z.ph:{show x; res:getRes[x]; show res;:res}

/Rest of Code

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
  qt:  update willsearch:1 from qt where keyc like "*search,value_", not valc like "";
  qt:  1!update column: {"I"$ssr[string x;"[a-zA-Z,_]";""]} each keyc from qt;

  qt
  }


getTable:{[qt]

  t: qt[`table][`valc];
  colsd: (0 +til count cols t)!cols t;
  ind: "I"$string (qt[`start][`valc];qt[`length][`valc]);
  trange:(ind 0)_(sum ind)#;

  table:(ind 0)_(sum ind)# ?[t;();0b;()];
  draw: "I"$string qt[`draw][`valc];
  recordsTotal: ?[t;();();(#:;`i)];

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
  query: x;
  qurl: x 0;
  qt: getQueryTable[qurl];
  td: getTable[qt];
  res: createJSON[td];
  :res
  }


