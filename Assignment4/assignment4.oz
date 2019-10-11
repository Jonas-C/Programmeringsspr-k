functor
import
  System
  OS
define
  
  % Helper function from assignment
  fun {RandomInt Min Max}
    X = {OS.rand}
    MinOS
    MaxOS
  in
    {OS.randLimits ?MinOS ?MaxOS}
    Min + X*(Max - Min) div (MaxOS - MinOS)
  end


  /*
  TASK 1
  */
  fun {GenerateOdd S E}
    if S mod 2 == 0 then {GenerateOdd S+1 E}
    elseif S > E then nil
    else S|{GenerateOdd S+2 E}
    end
  end


  /*
  TASK 2
  */
  fun {Product S}
    case S of nil then 1
    [] H|T then H*{Product T}
    end
  end


  /*
  TASK 3
  IS THIS SUPPOSED TO BE THE FIRST THREE RESULTS OF PRODUCT? IF SO I NEED TO CHANGE STUFF
  The first three digits are:

  The first three digits are: 100

  The biggest benefit threading brings is that many statements can essentially run at the same time.
  In this task, this means that the Product function can operate on the odd integer list before all the elements 
  have been calculated.
  */
  fun {GenerateOddProduct S E}
    local GO PGO in
      thread GO = {GenerateOdd S E} end
      thread PGO = {Product GO} end
      PGO
    end
  end


  /*
  TASK 4

  This is the rewritten GenerateOdd-function. 
  In terms of code efficiency, rewriting this function to be lazy eliminates an if check for each call.

  By using lazy functions throughput is strongly reduced. As for when it comes to resource usage, the lazy function will only 
  generate the requested values, and nothing more. If one were to generate all the odd numbers between
  0 and 1000 using a regular function and then realize that 1000 was supposed to be 1100, a regular function
  would have to perform the list creation from scratch. A lazy function, on the other hand, is always ready to 
  continue from the last calculation performed. 
  */
  fun lazy {GenerateOddLazy S}
    if S mod 2 == 0 then {GenerateOddLazy S+1}
    else S|{GenerateOddLazy S+2}
    end
  end


  /*
  TASK 5A
  */
  fun lazy {HammerFactory}
    thread
      {Delay 1000 }
      local X = {RandomInt 1 11} in
        if X > 9 then
          'defect'|{HammerFactory}
        else 'working'|{HammerFactory}
        end
      end
    end
  end


  /*
  TASK 5B
  IS THIS SUPPOSED TO HAVE A DELAY?
  */
  fun {HammerConsumer HammerStream N}
    if N == 0 then 0
    else 
      case HammerStream of nil then 0
      [] H|T then
        if H == 'working' then 1+{HammerConsumer T N-1}
        else {HammerConsumer T N-1}
        end
      end
    end
  end

  /*
  Task 5C
  */
  fun {Buffer N XS YS}


  {System.showInfo "======="}
  {System.showInfo "TASK 1"}
  {System.showInfo "======="}
  {System.showInfo "Input: {GenerateOdd ~3 10}"}
  {System.show {GenerateOdd ~3 10}}
  {System.showInfo "Input: {GenerateOdd 3 3}"}
  {System.show {GenerateOdd 3 3}}
  {System.showInfo "Input: {GenerateOdd 2 2}"}
  {System.show {GenerateOdd 2 2}}

  {System.showInfo "\n======="}
  {System.showInfo "TASK 2"}
  {System.showInfo "======="}
  {System.showInfo "Input: {Product [1 2 3 4]}"}
  {System.showInfo {Product [1 2 3 4]}}

  {System.showInfo "\n======="}
  {System.showInfo "TASK 3"}
  {System.showInfo "======="}
  {System.showInfo "Input: {GenerateOddProduct 0 1000}"}
  {System.showInfo {GenerateOddProduct 0 1000}}

  {System.showInfo "\n======="}
  {System.showInfo "TASK 4"}
  {System.showInfo "======="}
  {System.showInfo "Input: {GenerateOddLazy 0}"}
  {System.show {GenerateOddLazy 0}}

  {System.showInfo "\n======="}
  {System.showInfo "TASK 5A"}
  {System.showInfo "======="}
  {System.showInfo "Input: (The code snippet in the assignment (HammerTime.2.2.2.1))"}
  local HammerTime B in
    HammerTime = {HammerFactory}
    B = HammerTime.2.2.2.1
    {System.show HammerTime}
  end

  {System.showInfo "\n======="}
  {System.showInfo "TASK 5B"}
  {System.showInfo "======="}
  {System.showInfo "Input: (The code snippet in the assignment)"}
  local HammerTime Consumer in
    HammerTime = {HammerFactory}
    Consumer = {HammerConsumer HammerTime 10}
    {System.show Consumer}
  end





end
