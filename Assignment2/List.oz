/*
================
FILE DESCRIPTION
================

Jonas Ege Carlsen

This file contains the code for Task 1. The code for Task 2 can be found in mdc.oz
*/



/*
Helper function for the Length-function.
Recursively calls itself until it is at the end of the list. It then returns ListLength.
*/
fun {PLength List ListLength}
    case List of nil then ListLength    %If at end of list, return length
    [] Head|Tail then
        {PLength Tail ListLength+1}    %Call itself with List Tail and increment ListLength by 1.
    end
end



/*
The actual Length-function. Calls PLength with a ListLength of 0. Returns the length of the List-parameter.
*/   
fun {Length List}
    {PLength List 0}
end
 

/*
Returns the first n elements of a list by recursively building a list. While Count is greater than 0,
the function will check if the List still has elements that haven't been added. 
This is done by pattern matching. If there are un-added elements, the function recursively calls itself
with the tail of the current element while decrementing count by 1. 
If count is greater than the List, the entire list will be returned. 
*/   
fun {Take List Count}
    if Count > 0 then
        case List of nil then nil    %No more elements
        [] Head|Tail then    %If there are more elements, call itself with a decremented count.
            Head|{Take Tail Count-1} 
        end
    else nil
    end
end

/*
Returns the last N elements of a list. The first n elements will be excluded.
While Count is greater than zero the function will recursively call itself.
If it runs out of elements (or if count is negative), nil will be returned.
If there's still elements left when count reaches zero the rest of the List will be returned. 
*/
fun {Drop List Count}
    if Count > 0 then
        case List of nil then nil
        [] Head|Tail then {Drop Tail Count-1}    %Removes the head element until Count reaches 0.
    end
    else List
    end
end


/*
Appends List2 to the end of List1 and returns a List containing both. 
*/
fun {Append  List1 List2}
    case List1 of nil then    %End of List1 has been reached, and List2 can be appended.
        List2
    [] Head|Tail then    %Recursively calls itself until List1 reaches its end. 
        Head|{Append Tail List2}
    end
end


/*
Checks whether a particular Element is present in a List. Returns true if it is, false if it ain't.
*/
fun {Member List Element}
    case List of nil then false    %Returns false if the entire list has been ran through with no matches.
    [] Head|Tail then
        if Head == Element then true    %Element has been found
        else {Member Tail Element}    %Calls itself with the tail of the current Head Element as the List parameter.
        end
    end
end

/*
Helper function for the Position-function. Recursively calls itself until the parameter Element matches the current Element. 
The task stated that we should assume that the element is present, so I've omitted the code for checking that.
*/
fun {PPosition List Element Pos}
    case List of Head|Tail then
        if Head == Element then Pos    %Match, return position value.
        else {PPosition Tail Element Pos+1}    %Not a match, call itself the tail of the current Head element and increment pos-value by 1.
        end
    end
end


/*
The actual Position function. Calls PPosition with a Position value of 0.
*/   
fun {Position List Element}
    {PPosition List Element 0}
end