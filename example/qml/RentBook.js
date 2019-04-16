/*
* Copyright (c) 2011 Nokia Corporation.
*/

var date = new Date() // http://www.w3schools.com/js/js_obj_date.asp
var rentItems = null;

    function localeDate(day, month, year)
    {
        date.setFullYear(year, month-1, day); // year, month (0-based), day
        //return date.toLocaleDateString()
        //return date.toUTCString();
        return date.toDateString();
    }

