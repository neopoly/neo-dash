(function(){
    "use strict";

    // Times in millisecond
    var second = 1e3;
    var minute = 6e4;
    var hour   = 36e5;
    var day    = 864e5;
    var week   = 6048e5;

    var formats = {
        seconds: {
            short: 's',
            long: ' sec'
        },
        minutes: {
            short: 'm',
            long: ' min'
        },
        hours: {
            short: 'h',
            long: ' hr'
        },
        days: {
            short: 'd',
            long: ' day'
        }
    };


    var relativeFormat = function(format){
        var diff = Math.abs( this.diff(moment()) ),
            unit = null,
            num  = null;

        if(diff <= second){
            unit = 'seconds';
            num  = 1;
        }
        else if(diff < minute)
            unit = 'seconds';
        else if(diff < hour)
            unit = 'minutes';
        else if(diff < day)
            unit = 'hours';
        else if(format === 'short'){
            if(diff < week)
                unit = 'days';
            else
                return this.format('M/D/YY');
        }
        else
            return this.format('MMM D');

        if(!(num && unit))
            num = moment.duration(diff)[unit]();


        var unitStr = unit = formats[unit][format];
        if(format === 'long' && num > 1)
            unitStr += 's';

        return num + unitStr;
    };

    moment.fn.relative = moment.fn.relativeLong = function(){
        return relativeFormat.call(this, 'long');
    };

    moment.fn.relativeShort = function(){
        return relativeFormat.call(this, 'short');
    };
})();
