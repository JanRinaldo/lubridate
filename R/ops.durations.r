#' Daylight Savings Time
#'
#' Daylight Savings Time complicates mainpulating date-times. Time intervals that occur during a change in daylight savings time are not the same length as time intervals that occur on other dates. The Lubridate package supports two ways to resolve changes related to daylight savings time:
#'
#' If options(DST = "relative") has been set, adding across Daylight Savings Time changes will add or subtract an hour to retain a consistent clock time (the numbers that would appear on the face of a clock). This method is the default method of the lubridate package. 
#'
#' If options(DST = "exact") is set, the clock time of the new date-time will be one hour ahead or behind to maintain the exact length of time units. 
#'
#' The value of options("DST") determines which date-time lubridate returns when adding, subtracting, or setting elements of date-times.
#'
#' Adding, subtracting, or setting month and year values is handled the same by moth methods. Months and years are never exact lengths. The length of a month or year depends on the date-time on which it starts.  See \code{link{duration}} for more details. 
#'
#' @aliases daylightsavings DaylightSavings DaylightSavingsTime daylightSavings daylightsavingstime isdst daylightSavingsTime
#' @seealso \code{link{dst}}
#' @keywords utilities chron arith
#' @examples
#' date <- as.POSIXct("2009-03-08 01:59:00")
#' # "2009-03-08 01:59:00 CST"
#' 
#' ## relative - consistent clock time
#' options(DST = "relative")
#' date + days(1)
#' # "2009-03-09 01:59:00 CDT"
#' 
#' ## exact - consistent time lengths
#' options(DST = "exact")
#' date + days(1)
#' # "2009-03-09 02:59:00 CDT"
NULL



#' Addition for the duration class. 
#'
#' @aliases +.duration add_duration_to_date add_duration_to_duration add_number_to_duration +.POSIXt +.difftime +.Date
#' @method + duration
#' @method + POSIXt
#' @method + difftime
#' @method + Date
#' @param e1 a duration, difftime, POSIXt, or Date object
#' @param e2 a duration, difftime, POSIXt, or Date object
#' @return a new date-time or duration object, depending on e1 and e2 
#' @seealso \code{link{"-.duration"}, link{"*.duration"}, link{"/.duration"}}
#' @keywords arith chron methods
#' @ examples
#' x <- new_duration(day = 1)
#' x + Sys.time()
#' Sys.Date + x
#' x + difftime(Sys.time() + 3600, Sys.time())
#' x + x



add_period_to_date <- function(date, period){
	datetest <- date

	year(date) <- year(date) + period$year
	month(date) <- month(date) + period$month
	mday(date) <- mday(date) + period$day
	hour(date) <- hour(date) + period$hour
	minute(date) <- minute(date) + period$minute
	second(date) <- second(date) + period$second

	if(is.Date(datetest))
		return(with_tz(date, "UTC"))
	date
}

add_duration_to_date <- function(date, duration) {
	if(is.Date(date)){
		date <- as.POSIXct(date)
		ans <- with_tz(base::'+.POSIXt'(date, duration), "UTC")
		if (hour(ans) == 0 && minute(ans) == 0 && second(ans) == 0)
			return(as.Date(ans))
		return(ans)
	}
	base::'+.POSIXt'(date, duration)
}

add_number_to_duration <- function(dur, num)
	make_difftime(num + as.double(dur, "secs"))

add_number_to_period <- function(per, num){
	message("numeric coerced to seconds")
	per$second <- per$second + num
	per
}
	
add_period_to_period <- function(per1, per2){
	class(per1) <- "data.frame" 
	class(per2) <- "data.frame"
	structure(per1 + per2, class = c("period", "data.frame"))
}
	
add_duration_to_period <- function(dur, per){
	stop("incompatible time spans. See 'interval' documentation.")
	# per + seconds(as.double(dur, "secs"))
}
	
add_duration_to_duration <- function(dur1, dur2)
	make_difftime(as.double(dur1, "secs") + as.double(dur2, "secs"))

add_duration_to_interval <- function(int, dur){
	int$end <- int$end + dur
	int
}
	
add_period_to_interval <- function(int, per){
	int$end <- int$end + per
	int
}

add_number_to_interval <-function(int, num){
	message("numeric coerced to duration in seconds")
	int$end <- int$end + as.duration(num)
	int
}

"+.period" <- "+.POSIXt" <- "+.difftime" <- "+.interval" <- "+.Date" <- function(e1, e2){
	
	if (is.instant(e1)) {
		if (is.instant(e2))
			stop("binary '+' not defined for adding dates together")
		if (is.interval(e2))
			stop("binary '+' not defined for adding dates together")
		if (is.period(e2))
			add_period_to_date(e1, e2)
		else if (is.difftime(e2)) 
			add_duration_to_date(e1, e2)
		else if (is.POSIXt(e1))
			structure(unclass(as.POSIXct(e1)) + e2, class = c("POSIXt", "POSIXct"))
		else if (is.Date(e1))
			structure(unclass(e1) + e2, class = "Date")
		else
			base::'+'(e1,e2)
	}

	else if (is.period(e1)) {
		if (is.instant(e2))
			add_period_to_date(e2, e1)
		else if (is.period(e2))
			add_period_to_period(e1, e2)
		else if (is.difftime(e2))
			add_duration_to_period(e1, e2)
		else if (is.interval(e2))
			add_period_to_interval(e2, e1)
		else
			add_number_to_period(e1, e2)
	}

	else if (is.difftime(e1)) {
		if (is.instant(e2))
			add_duration_to_date(e2, e1)
		else if (is.period(e2))
			add_duration_to_period(e2, e1)
		else if (is.difftime(e2))
			add_duration_to_duration(e1, e2)
		else if (is.interval(e2))
			add_duration_to_interval(e2, e1)
		else
			add_number_to_duration(e1, e2)
	}
	
	else if (is.interval(e1)){
		if (is.instant(e2))
			stop("binary '+' not defined for adding dates together")
		if (is.interval(e2))
			stop("binary '+' not defined for adding dates together")
		else if (is.period(e2))
			add_period_to_interval(e1, e2)
		else if (is.duration(e2))
			add_duration_to_interval(e1, e2)	
		else
			add_number_to_interval(e1, e2)
	}
	else if (is.numeric(e1)) {
		if (is.POSIXt(e2))
			structure(unclass(as.POSIXct(e2)) + e1, class = c("POSIXt", "POSIXct"))
		else if (is.Date(e1))
			structure(unclass(e2) + e1, class = "Date")
		else if (is.period(e2))
			add_number_to_period(e2, e1)
		else if (is.difftime(e2))
			add_number_to_duration(e2, e1)
		else if (is.interval(e2))
			add_number_to_interval(e2, e1)	
		else stop("Unknown object class")
	}
	else stop("Unknown object class")
}



#' Makes a difftime object from given number of seconds 
#'
#' @param x number value of seconds to be transformed into a difftime object
#' @return a difftime object corresponding to x seconds
#' @keywords chron
#' @ examples
#' make_difftime(1)
#' make_difftime(60)
#' make_difftime(3600)
make_difftime <- function (x) {  
	seconds <- abs(x)
    if (seconds < 60) 
        units <- "secs"
    else if (seconds < 3600)
        units <- "mins"
    else if (seconds < 86400)
        units <- "hours"
    else if (seconds < 604800)
    	units <- "days"
    else units <- "weeks"
    
    switch(units, secs = structure(x, units = "secs", class = "difftime"), 
    	mins = structure(x/60, units = "mins", class = "difftime"), 
    	hours = structure(x/3600, units = "hours", class = "difftime"), 
    	days = structure(x/86400, units = "days", class = "difftime"), 
    	weeks = structure(x/(604800), units = "weeks", class = "difftime"))
}

#' Multiplication for the duration class. 
#'
#' @aliases *.duration multiply_duration_by_numeric 
#' @method * duration
#' @param e1 a duration or numeric object
#' @param e2 a duration or numeric object
#' @return a duration object
#' @seealso \code{link{"+.duration"}, link{"-.duration"}, link{"/.duration"}}
#' @keywords arith chron methods
#' @ examples
#' x <- new_duration(day = 1)
#' x * 3
#' 3 * x
"*.period" <- "*.interval" <- function(e1, e2){
    if (is.timespan(e1) && is.timespan(e2)) 
    	stop("cannot multiply time span by time span")
    else if (is.period(e1))
    	multiply_period_by_number(e1, e2)
    else if (is.period(e2))
    	multiply_period_by_number(e2, e1)
    else if (is.interval(e1))
    	multiply_interval_by_number(e1, e2)
    else if (is.interval(e2))
    	multiply_interval_by_number(e2, e1)
    else base::'*'(e1, e2)
}  

multiply_period_by_number <- function(per, num){
	new_period(
		year = per$year * num,
		month = per$month * num,
		day = per$day * num,
		hour = per$hour * num,
		minute = per$minute * num,
		second = per$second * num
	)
}

multiply_interval_by_number <- function(int, num){
	diff <- difftime(int$end, int$start) * num
	new_interval(int$start, int$start + diff)
}


#' Division for the duration class. 
#'
#' @aliases /.duration divide_duration_by_numeric 
#' @method / duration
#' @param e1 a duration or numeric object
#' @param e2 a duration or numeric object
#' @return a duration object
#' @seealso \code{link{"+.duration"}, link{"-.duration"}, link{"*.duration"}}
#' @keywords arith chron methods
#' @ examples
#' x <- new_duration(day = 1)
#' x / 2
#' 2 / x
"/.period" <- "/.interval" <- function(e1, e2){
 	if (is.timespan(e2)) 
  		stop( "second argument of / cannot be a timespan")
  	else if (is.period(e1))
    	divide_period_by_number(e1, e2)
    else if (is.interval(e1))
    	divide_interval_by_number(e1, e2)
    else base::'/'(e1, e2)
}  

divide_period_by_number <- function(per, num){
	new_period(
		year = per$year / num,
		month = per$month / num,
		day = per$day / num,
		hour = per$hour / num,
		minute = per$minute / num,
		second = per$second / num
	)
}

divide_interval_by_number <- function(int, num){
	diff <- difftime(int$end, int$start) / num
    new_interval(int$start, int$start + diff)
}

  
#' Subtraction for the duration class. 
#'
#' The subtraction methods also return a duration object when a POSIXt or Date object is subtracted from another POSIXt or Date object. To retrieve this difference as a difftime, use \code{link{as.difftime}}. 
#'
#' Since a specific number of seconds exists between two dates, the duration returned will not include unspecific time units such as years and months. To get a nonspecific duration use \code{link{get_duration}}. See \code{link{duration}} for more details.
#'
#' @aliases -.duration -.POSIXt -.difftime -.Date
#' @method - duration
#' @method - POSIXt
#' @method - difftime
#' @method - Date
#' @param e1 a duration, difftime, POSIXt, or Date object
#' @param e2 a duration, difftime, POSIXt, or Date object
#' @return a new date-time or duration object, depending on e1 and e2 
#' @seealso \code{link{"+.duration"}, link{"*.duration"}, link{"/.duration"}}
#' @keywords arith chron methods
#' @ examples
#' x <- new_duration(day = 1)
#' Sys.time() - x
#' -x
#' x - x
#' as.Date("2009-08-02") - as.Date("2008-11-25")
"-.period" <- "-.POSIXt" <- "-.difftime" <- "-.interval" <- "-.Date" <- function(e1, e2){
	if (missing(e2))
		-1 * e1
	else if(is.instant(e1) && is.instant(e2))
		new_interval(e1, e2)
	else if (is.POSIXt(e1) && !is.timespan(e2))
		structure(unclass(as.POSIXct(e1)) - e2, class = c("POSIXt", "POSIXct"))
	else		
		e1  + (-1 * e2)
}




