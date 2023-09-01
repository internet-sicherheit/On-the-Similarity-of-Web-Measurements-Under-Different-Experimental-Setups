-- This SQL contains SQL functions used in Bigquery.

CREATE OR REPLACE FUNCTION `your-bigquery-data-set.diff.fc_cleanQueryString`(url STRING) RETURNS STRING LANGUAGE js AS R"""
if (url.includes('?')) {

        queryString = url.split('?')

        url_path = queryString[0]
        queryString.shift()

        queryString = queryString.join('?')

        params = queryString.split('&')

        paramsClean = []
        for (let i = 0; i < params.length; i++) {
            item = params[i].split('=')[0] + "={}"
            paramsClean.push(item)
        }
        paramsClean = paramsClean.join('&') 
 
        full_url= url_path + '?' + paramsClean
        return full_url;

    }
    else
        return url;
""";



CREATE OR REPLACE FUNCTION `your-bigquery-data-set.diff.fc_extractCallStack`(calls STRING) RETURNS ARRAY<STRING> LANGUAGE js AS R"""
reg = /[@]+(http:|https:|ftp:|ftps:|ws:|wss:)+(.*?)(([:]+[0-9]+[:]+[0-9]+[;]+)|( line [0-9]+ ))/gi
     /*
    calls = `
value@https://1.com:362:25;null
value@https://2.com:1:30329;null
value@https://2.com:1:23700;null
value@https://7.com:1:23700;null
value@https://2.com:1:23700;null
value@https://2.com:1:23700;null
value@https://3.com:1:23299;null
value@https://3.com:1:23299;null
value@https://3.com:1:23299;null
value@https://4.com:1:22815;null
value@https://3.com:1:22575;null
value@https://2.com:1:10010;null
value@https://5.com:1:51142;null `
*/
    var myList = [];

    try {
    calls.match(reg).forEach((item) => {
        item = item.replace(/(([:]+[0-9]+[:]+[0-9]+[;]+)|( line [0-9]+ ))(.*?)*/g, '')
        if (myList[myList.length - 1] != item) {
            myList.push(item);
        }
    });
 
} catch (e) {
    return []
}
    //myList = myList.reverse()

    //document.write("myList<br>" + myList + "<hr>")
    var results = [];
    dist_List = []

    for (let i = 0; i < myList.length; i++) {
        if (dist_List.includes(myList[i]) == false) {
            dist_List.push(myList[i]);
        }
    }
   // document.write("distinct: " + dist_List + "<br>")


    var results = []
    //find the parents
    for (let i = 0; i < dist_List.length; i++) {
        row = dist_List[i]

       // document.write("<br> " + dist_List[i])
        parents = []
        for (let t = 0; t < myList.length; t++) {
            if (myList[t] == dist_List[i]) {
                if (t + 1 != myList.length) {
                    //results.push(t);
                    parents.push("||parent||"+myList[t + 1])
                }
            }
        }


        parents = parents.filter(function (value, index, array) { 
            return parents.indexOf(value) === index;
        });

    //    document.write(dist_List[i] + "||:parents:||" + parents)
        results.push(dist_List[i] + "||:parents:||" + parents)
    }

    final_results = []
    for (let i = 0; i < results.length; i++) {
        final_results.push(i + "||:delimeter:||" + results[i])
    } 

    console.log(results)
    console.log(final_results)

    return final_results
""";

CREATE OR REPLACE FUNCTION `your-bigquery-data-set.diff.fc_jsonModify`(js STRING, key STRING, newValue NUMERIC, i INT64) RETURNS STRING LANGUAGE js AS R"""
obj = JSON.parse(js)
    obj[i][key] = newValue;
    return JSON.stringify(obj);
""";


CREATE OR REPLACE FUNCTION `your-bigquery-data-set.diff.fc_sim_array`(arr STRING) RETURNS NUMERIC LANGUAGE js AS R"""
all = arr.split('|')
        arrList = []

        for (let i = 0; i < all.length; i++) {
            val1 = all[i]
            if (val1 == null) { val1 = ""; }
            val1 = val1.split(',')
            val1 = val1.filter(function (value, index, array) {
                return array.indexOf(value) === index;
            });
            arrList.push(val1)
        } 

        maxLength = -1;
        for (let i = 0; i < arrList.length; i++) {
            if (maxLength < arrList[i].length) {
                maxLength = arrList[i].length;
            }
        }

        var arrLength = Object.keys(arrList).length;
        var index = {};
        for (var i in arrList) {
            for (var j in arrList[i]) {
                var v = arrList[i][j];
                if (index[v] === undefined) index[v] = 0;
                index[v]++;
            };
        };
        var retv = [];
        for (var i in index) {
            if (index[i] == arrLength) retv.push(i);
        };

        commonItem = retv.length 
        return (parseInt(commonItem) / parseInt(maxLength)).toFixed(2)
""";


CREATE OR REPLACE FUNCTION `your-bigquery-data-set.diff.sim_array`(x ANY TYPE, y ANY TYPE) AS (
    (
        SELECT
          string_AGG(DISTINCT xe)
        FROM
          UNNEST(split(x)) AS xe
        INNER JOIN (
          SELECT
            ye
          FROM
            UNNEST(split(y)) AS ye)
        ON
          xe = ye)
    );