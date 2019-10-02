function logical = contains(str1,str2)
    n1 = length(str1);
    n2 = length(str2);
    logical = false;   
    for idx = 1:(n1-n2+1)
       if strcmp(str1(idx:(idx+n2-1)),str2)
           logical = true;
           break
       end
    end
end