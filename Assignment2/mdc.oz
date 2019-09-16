functor
import
   System
define
   \insert List.oz

    /*
    ================
    FILE DESCRIPTION
    ================

    Jonas Ege Carlsen

    This file contains all code related to Task 2 and Task 3. Task 1 can be found in List.oz.
    Each function has a description as well as plenty of comments. 
    I have also provided a high-level description of both how my MDC works and how I convert postfix to infix.
    */


    /*
    =============================
    HIGH-LEVEL DESCRIPTION OF MDC
    =============================

    The entire mdc process starts with creating a list of Lexemes; This is done by the Lex-function. This function takes a String-input
    and splits it for every :space: used. If the input is invalid an exception will be raised. An example output should look something like this:
    Input: "1 2 3 +"
    [[1] [2] [3] [+]] (or its ASCII equivalent)

    Once you have a list of lexemes they should be converted into a list of records (also referred to as tokens).
    This is done by the Tokenize-function. The function defines a set of commands and operators that are allowed to be turned into tokens. 
    For each Lexeme in the input list a function is ran. This function checks if the current Lexeme is either a Command, an operator or a Number.
    If it is, it's converted to an appropriate record. If it isn't, an exception is raised.
    An example output should look something like this:
    Input: The output from the Lex-description above.
    [number(1) number(2) number(3) operator(type:'+')]

    At this point, the mdc interpreter can take over. The function takes in a list of tokens.
    The function defines what actions are to be taken for specific operations and commands. These can be found in the Commands- and Operators-records.
    The interpret-function then attempts to call the nested function "Iterate" with the tokens it has received and an empty stack.
    The iterate-function will recursively call itself until it runs out of tokens. At that point the stack will be returned.
    While there's still tokens, Iterate will distinguish between commands, operators and numbers. 
    Numbers are added to the start of the stack, followed by the function calling itself.
    If the current token is a command, some action will be performed on the stack. These actions are defined in the Commands-record mentioned above.
    The function will then call itself again.
    When the current Token is an operator the function will divide the stack into three parts: The top element, the next-to-top element and the rest of the stack.
    The operator will be applied on the top- and next-to-top-elements and the result will be put at the start of the stack, followed by the rest of the stack.
    After this has been done the function will call itself once again.
    An example output should look something like this:
    Input: The output from the Tokenize-description above.
    [number(1) number(5)]

    */

    /*
    Converts a String to an array of Lexemes by using the String.tokens function.
    Strings.tokens splits the string into substrings every time a space occurs in the string.
    Raises an exception if Input is not a string.  */
    fun {Lex Input}
        if {IsString Input} then   %Input is a string
            {String.tokens Input & }     %Splits string into substrings
        else raise "invalid input" end   %Input is not a string
        end
    end



    /*
    Converts Lexemes into a List of Records by checking the "type" of the current Lexeme. Commands and operators are
    compared to predefined lists of accepted inputs. If the Lexeme is neither, the function checks if it's a Number. If not, it throws an Exception.
    The function utilizes the Map-function, which runs a function (the anonymous one, marked with $) on each Lexeme in the List that's passed in.
    */
    fun {Tokenize Lexemes}
        Commands = ["p" "d" "i" "^"]  %Available commands
        Operators = ["+" "-" "*" "/"] %Available operators
    in
        {Map Lexemes   %Runs {$ Lexeme} on each Lexeme in the list.
            fun {$ Lexeme}
                if {Member Commands Lexeme} then    %If Lexeme is a command, make a command record.
                    command({String.toAtom Lexeme})
                elseif {Member Operators Lexeme} then   %Same as above, but with operators.
                    operator(type:{String.toAtom Lexeme})
                else
                    try number({String.toFloat Lexeme})  %Tries to create a number-record with the Lexeme as the value.
                    catch _ then 
                        raise "invalid lexeme" end    %Raises an Exception if the lexeme wasn't a number.
                    end
                end
            end
        }
    end



   /*
   The Interpret function interprets a list of tokens and performs certain actions based on the content in the list of tokens. 
   It consists of two records (command and operators) that define the actions that are interpretable. There's also a nested function
   that recursively calls itself and goes through the Tokens.
   The function ends with a try/catch, that makes sure that operations can't be performed on an empty stack. The try-part also passes in nil as an 
   argument to the Iterate-function so that everything functions properly.
   */
   fun {Interpret Tokens}
        Commands = command(    %A record which contains different procedures and functions that can be called.
            p:fun {$ Stack}    %Reverses the Stack and prints it. Returns the original stack   
                {System.show {Tokenize {Reverse Stack}}}
                Stack
            end
         
            d:fun {$ Stack}
                case Stack of Head|Tail then
                    Head|Head|Tail    %Return a duplication of the Stack head
			    else raise "Stack Empty" end    %Raises an exception if the stack is empty.
                end
            end

            i:fun {$ Stack} 
                case Stack of Head|Tail then
                    ~Head|Tail    %Flip the sign of the Head Element and return the modified Head and the original tail.
                else raise "Stack empty!" end
                end
            end

            '^':fun {$ Stack}
                case Stack of Head|Tail then
                    (1.0 / Head)|Tail    %Calculates the multiplicative inverse of the Head Element and returns the modified Head and the original Tail.
                else raise "Stack empty!" end
                end
            end             
        )

        Operators = operators(    %A record which contains functions that perform operations on numbers or floats.
            '+':Number.'+'
            '-':Number.'-'
            '*':Number.'*'
            '/':Float.'/')
		     
        
        /*
        This function does the brunt of the work. It calls itself recursively and performs actions based on the type of token that is being processed.
        Numbers are moved to the Stack, commands perform actions on the stack and the operators perform some kind of operation on the numbers in the stack.
        The three types are separated with the help of pattern matching (cases). When there are no more tokens the stack is reversed, tokenized and returned. 
        */
        fun {Iterate Stack Tokens}    %Nested function
            case Tokens of nil then    %Tokens List is empty. Reverse, Tokenize and return the Stack.
                {Tokenize {Reverse Stack}}
            [] number(Number)|Tokens then    %If the current Token is a number, call itself with the Number in the Stack.
                {Iterate Number|Stack Tokens}
            [] command(Command)|Tokens then    %If the current Token is a command, perform the command.
                {Iterate {Commands.Command Stack} Tokens}
            [] operator(type:Operator)|Tokens then    
            %If the current Token is an operator. perform an operation on the two topmost numbers in the stack. Place the result back in the stack with the rest appended.
                Top|NextToTop|Rest = Stack in
                    {Iterate {Operators.Operator NextToTop Top}|Rest Tokens}
            end
        end
    in
        {Iterate nil Tokens}
        /*try
            {Iterate nil Tokens}
        catch _ then
            raise "stack empty" end
        end
        */
   end



    /*
    =====================================================
    HIGH-LEVEL DESCRIPTION OF CONVERTING POSTFIX TO INFIX
    =====================================================

    Takes in a postfix expression and converts it to an infix expression by recursively calling the nested function.
    The outer function does this by calling the nested function with the list of Tokens it received alongside an ExpressionStack
    that is nil (for now). The nested InfixInternal checks what the current token is. If there are no tokens left, the function is done and the 
    stack is returned. If the current Token is a number it's added to the start of the ExpressionStack.
    If the current Token is an operator the ExpressionStack is divided in three: The top element, the next to top-element and the rest of the Stack.
    The function will then call itself again. But before this call happens, a VirtualString is added to the start of the ExpressionStack. 
    This VirtualString consists of a parentheses, followed by the NextToTop-value, a space, the operator, another space, the Top-value and then a closing parentheses.
    By doing it this way it ensures that the final expression will be displayed in a non-ambiguous way.
    */
    fun {Infix Tokens}
        fun {InfixInternal Tokens ExpressionStack}    %Nested function
            case Tokens of nil then    %Tokens are empty, return the stack.
                ExpressionStack
            [] number(Number)|Tokens then    %If number, add to front of stack. Call itself. 
                {InfixInternal Tokens Number|ExpressionStack}
            [] operator(type:Operator)|Tokens then    
            /*
            If operator, create a VirtualString with the following order: "("NextToTop (space) Operator (space) Top")".
            Add this string to the front of the list and append the rest to the end. Call itself and repeat.
            */
                Top|NextToTop|Rest = ExpressionStack in
                    {InfixInternal Tokens "("#NextToTop#" "#Operator#" "#Top#")"|Rest}
            end
        end
    in
        try
            {InfixInternal Tokens nil}.1
        catch _ then
            raise "Stack empty!" end
        end
    end
   

    {System.showInfo "\nTASK 1A"}
    {System.showInfo "Input: 1|2|3|4|nil"}
    {System.show {Length 1|2|3|4|nil}}
    {System.showInfo "\nTask 1B"}
    {System.showInfo "Input: 1|2|3|4|5|nil 8"}
    {System.show {Take 1|2|3|4|5|nil 8}}
    {System.showInfo "\nTask 1C"}
    {System.showInfo "Input: 1|2|3|4|5|nil"}
    {System.show {Drop 1|2|3|4|5|nil 2}}
    {System.showInfo "\nTask 1D"}
    {System.showInfo "Input: 1|2|3|4|5|nil 6|7|8|9|nil"}
    {System.show {Append 1|2|3|4|5|nil 6|7|8|9|nil}}
    {System.showInfo "\nTask 1E"}
    {System.showInfo "Input: 1|2|3|4|5|nil"}
    {System.show {Member 1|2|3|4|5|nil 7}}
    {System.showInfo "\nTask 1F"}
    {System.showInfo "Input: 1|2|3|4|5|nil"}
    {System.show {Position 1|2|3|4|5|nil 3}}

    {System.showInfo "\n\nTASK 2A"}
    {System.showInfo "Input: \"1 2 + 3 *\""}
    {System.show {Lex "1 2 + 3 *"}}
    {System.showInfo "\nTASK 2B"}
    {System.showInfo "Input: [\"1\" \"2\" \"+\" \"3\" \"*\"]"}
    {System.show {Tokenize ["1" "2" "+" "3" "*"]}}
    {System.showInfo "\nTASK 2C"}
    {System.showInfo "Input: [number(1.0) number(2.0) number(3.0) operator('+')]"}
    {System.show {Interpret [number(1.0) number(2.0) number(3.0) operator(type:'+')]}}
    {System.showInfo "\nTASK 2D"}
    {System.showInfo "Input: [number(1.0) number(2.0) number(3.0) command('p') operator('+')]"}
    {System.show {Interpret [number(1.0) number(2.0) number(3.0) command('p') operator(type:'+')]}}
    {System.showInfo "\nTASK 2E"}
    {System.showInfo "Input: [number(1.0) number(2.0) number(3.0) operator('+') command('d')]"}
    {System.show {Interpret [number(1.0) number(2.0) number(3.0) operator(type:'+') command('d')]}}
    {System.showInfo "\nTASK 2F"}
    {System.showInfo "Input: [number(1.0) number(2.0) number(3.0) operator('+') command('i')]"}
    {System.show {Interpret [number(1.0) number(2.0) number(3.0) operator(type:'+') command('i')]}}
    {System.showInfo "\nTASK 2G"}
    {System.showInfo "Input: [number(1.0) number(2.0) number(3.0) operator('+') command('^')]"}
    {System.show {Interpret [number(1.0) number(2.0) number(3.0) operator(type:'+') command('^')]}}

    {System.showInfo "\n\nTask 3"}
    {System.showInfo "Input: {Infix {Tokenize {Lex \"3.0 10.0 9.0 * - 0.3 +\"}}}"}
    {System.showInfo {Infix {Tokenize {Lex "3.0 10.0 9.0 * - 0.3 +"}}}}

 
end
