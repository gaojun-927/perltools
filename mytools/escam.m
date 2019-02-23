%This program takes a netlist (similar to SPICE), parses it to derive the
%circuit equations, then solves them symbolically.  
%
%Full documentation available at www.swarthmore.edu/NatSci/echeeve1/Ref/mna/MNA1.html
%
% AX=Z
%    |G B|   |V|   |I|
%  A=|C D| X=|J| Z=|E|
%

%gaojun 2009/02/04
%fix matric build error when read unsupported device
%support .xxx statement to finish read
%derived from scam, to extend scam. by gaojun 2009/01/06
%1. the origin need RLC, the new need RLCrlc
%2. the origin need node to be number and from 0 to N continuously. the new
%can accept string
%3. the origin do not accpet VCVS(e) vccs(g) the new can accept g

disp(sprintf('\n\nStarted -- please be patient.\n'));

[Name N1 N2 N3 N4 arg]=textread(fname,'%s %s %s %s %s %s'); 
n=length(Name);
if length(N3)<n N3{n}='';
end
if length(N4)<n N4{n}='';
end
if length(arg)<n arg{n}='';
end
nodecount=0;eq=0;nodemap={''};
for i=1:n
   switch(Name{i}(1)),
       case {'R','L','C','r','l','c','V','v','O','o','I','i','E','e','G','g'},
           if(find(strcmp(nodemap,N1{i})))
           else
               nodecount=nodecount+1;
               nodemap(nodecount)={ N1{i} };
           end
           if(find(strcmp(nodemap,N2{i})))
           else
               nodecount=nodecount+1;
               nodemap(nodecount)={ N2{i} };
           end
           if(N4{i})
               if(find(strcmp(nodemap,N3{i})))
               else
                   nodecount=nodecount+1;
                   nodemap(nodecount)={ N3{i} };
               end
               if(find(strcmp(nodemap,N4{i})))
               else
                   nodecount=nodecount+1;
                   nodemap(nodecount)={ N4{i} };
               end
           end
       case {'.'},
           break;
       otherwise,
   end
end

%to delete 0 node
nodemap( find(strcmp(nodemap,'0')) )=[];       
 
tic
%Initialize
numElem=0;  %Number of passive elements.
numV=0;     %Number of independent voltage sources
numO=0;     %Number of op amps
numI=0;     %Number of independent current sources
numNode=0;  %Number of nodes, not including ground (node 0).
numVCVS=0;
numVCCS=0;
numCCCS=0; %unsupport until now because it will add current var

%Parse the input file
for i=1:length(Name),
    switch(Name{i}(1)),
        case {'R','L','C','r','l','c'},
            numElem=numElem+1;
            Element(numElem).Name=Name{i};
            Element(numElem).Node1=find(strcmp(nodemap,N1{i}));
            Element(numElem).Node2=find(strcmp(nodemap,N2{i}));
            try
                Element(numElem).Value=str2num(N3{i});
            catch
                Element(numElem).Value=nan;
            end
        case {'V','v'}
            numV=numV+1;
            Vsource(numV).Name=Name{i};
            Vsource(numV).Node1=find(strcmp(nodemap,N1{i}));
            Vsource(numV).Node2=find(strcmp(nodemap,N2{i}));
            try
                Vsource(numV).Value=str2num(N3{i});
            catch
                Vsource(numV).Value=nan;
            end
        case {'O','o'}
            numO=numO+1;
            Opamp(numO).Name=Name{i};
            Opamp(numO).Node1=find(strcmp(nodemap,N1{i}));
            Opamp(numO).Node2=find(strcmp(nodemap,N2{i}));
            Opamp(numO).Node3=find(strcmp(nodemap,N3{i}));
        case {'I','i'}
            numI=numI+1;
            Isource(numI).Name=Name{i};
            Isource(numI).Node1=find(strcmp(nodemap,N1{i}));
            Isource(numI).Node2=find(strcmp(nodemap,N2{i}));
            try
                Isource(numI).Value=str2num(N3{i});
            catch
                Isource(numI).Value=nan;
            end
        case {'E','e'},
            numVCVS=numVCVS+1;
            VCVS(numVCVS).Name=Name{i};
            VCVS(numVCVS).Node1=find(strcmp(nodemap,N1{i}));
            VCVS(numVCVS).Node2=find(strcmp(nodemap,N2{i}));
            VCVS(numVCVS).Node3=find(strcmp(nodemap,N3{i}));
            VCVS(numVCVS).Node4=find(strcmp(nodemap,N4{i}));
            try
                VCVS(numVCVS).Value=str2num(arg{i});
            catch
                VCVS(numVCVS).Value=nan;
            end   
      case {'G','g'},
            numVCCS=numVCCS+1;
            VCCS(numVCCS).Name=Name{i};
            VCCS(numVCCS).Node1=find(strcmp(nodemap,N1{i}));
            VCCS(numVCCS).Node2=find(strcmp(nodemap,N2{i}));
            VCCS(numVCCS).Node3=find(strcmp(nodemap,N3{i}));
            VCCS(numVCCS).Node4=find(strcmp(nodemap,N4{i}));
            try
                VCCS(numVCCS).Value=str2num(arg{i});
            catch
                VCCS(numVCCS).Value=nan;
            end   
      case {'F','f'},
            numCCCS=numCCCS+1;
            CCCS(numCCCS).Name=Name{i};
            CCCS(numCCCS).Node1=find(strcmp(nodemap,N1{i}));
            CCCS(numCCCS).Node2=find(strcmp(nodemap,N2{i}));
            CCCS(numCCCS).Node3=find(strcmp(nodemap,N3{i}));
            CCCS(numCCCS).Node4=find(strcmp(nodemap,N4{i}));
            try
                CCCS(numCCCS).Value=str2num(arg{i});
            catch
                CCCS(numCCCS).Value=nan;
            end 
            error('Do not support CCCS');
        case {'.'},
            break;
        otherwise,
            warning('Do not support unknown device');
            warning('skip this card');
    
    end
    
    
    %numNode=max(str2num(N1{i}),max(str2num(N2{i}),numNode));
    numNode=length(nodemap);
end

%Preallocate all of the cell arrays #################################
G=cell(numNode,numNode);
V=cell(numNode,1);
I=cell(numNode,1);
num2=numV+numO+numVCVS+numCCCS;%extra current var
if ((num2)~=0),
    B=cell(numNode,num2);
    C=cell(num2,numNode);
    D=cell(num2,num2);
    E=cell(num2,1);
    J=cell(num2,1);
end
%Done preallocating cell arrays -------------------------------------

%Fill the G matrix ##################################################
%Initially, make the G Matrix all zeros.
[G{:}]=deal('0');

%Now fill the G matrix with conductances from netlist
for i=1:numElem,
    n1=Element(i).Node1;
    n2=Element(i).Node2;
    %Make up a string with the conductance of current element.
    switch(Element(i).Name(1)),
        case {'R','r'}
            g = ['1/' Element(i).Name];
        case {'L', 'l'}
            g = ['1/s/' Element(i).Name];
        case {'C', 'c'}
            g = ['s*' Element(i).Name];
    end
    
    %If neither side of the element is connected to ground
    %then subtract it from appropriate location in matrix.
    if (n1~=0) & (n2~=0),
        G{n1,n2}=[ G{n1,n2} '-' g];
        G{n2,n1}=[ G{n2,n1} '-' g];
    end
    
    %If node 1 is connected to graound, add element to diagonal
    %of matrix.
    if (n1~=0),
        G{n1,n1}=[ G{n1,n1} '+' g];
    end
    %Ditto for node 2.
    if (n2~=0),
        G{n2,n2}=[ G{n2,n2} '+' g];
    end
    
    %Go to next element.
    %     i=i+4;
end
%fill G with VCCS gm
for i=1:numVCCS,
    n1=VCCS(i).Node1;
    n2=VCCS(i).Node2;
    n3=VCCS(i).Node3;
    n4=VCCS(i).Node4;
    %Make up a string with the conductance of current element.

    g = [VCCS(i).Name];

    
    %If neither side of the element is connected to ground
    %then subtract it from appropriate location in matrix.
    if (n2~=0) & (n3~=0),
        G{n2,n3}=[ G{n2,n3} '-' g];
    end
    if (n1~=0) & (n4~=0)
        G{n1,n4}=[ G{n1,n4} '-' g];
    end
    
    %If node 1 is connected to graound, add element to diagonal
    %of matrix.
    if (n1~=0) & (n3~=0),
        G{n1,n3}=[ G{n1,n3} '+' g];
    end
    %Ditto for node 2.
    if (n2~=0) & (n4~=0),
        G{n2,n4}=[ G{n2,n4} '+' g];
    end
    
    %Go to next element.
    %     i=i+4;
end
%The G matrix is finished -------------------------------------------

%Fill the I matrix ##################################################
[I{:}]=deal('0');
for j=1:numNode,
    for i=1:numI,
        if (Isource(i).Node1==j),
            I{j}=[I{j} '-' Isource(i).Name];
        elseif (Isource(i).Node2==j),
            I{j}=[I{j} '+' Isource(i).Name];
        end
    end
end
%The I matrix is done -----------------------------------------------

%Fill the V matrix ##################################################
for i=1:numNode,
    tt=cell2mat(nodemap(i));
    V{i}=['v_' tt];
end
%The V matrix is finished -------------------------------------------

if ((num2)~=0), %add new current var as V, VCVS, CCCS,O
    %Fill the B matrix ##################################################
    %Initially, fill with zeros.
    [B{:}]=deal('0');
    
    %First handle the case of the independent voltage sources.
    for i=1:numV,           %Go through each independent source.
        for j=1:numNode     %Go through each node.
            if (Vsource(i).Node1==j),       %If node is first node,
                B{j,i}='1';                 %then put '1' in the matrices.
            elseif (Vsource(i).Node2==j),   %If second node, put -1.
                B{j,i}='-1';
            end
        end
    end
    index=numV;
   %case of VCVS 
   for i=1:numVCVS,           %Go through each independent source.
        for j=1:numNode     %Go through each node.
            if (VCVS(i).Node1==j),       %If node is first node,
                B{j,i+index}='1';                 %then put '1' in the matrices.
            elseif (VCVS(i).Node2==j),   %If second node, put -1.
                B{j,i+index}='-1';
            end
        end
   end
   index=index+numVCVS;
    %case of CCCS
   for i=1:numCCCS,           %Go through each independent source.
        B{CCCS(i).Node1,i+index}=[B{CCCS(i).Node1,i+index} '+' CCCS(i).Value];
        B{CCCS(i).Node2,i+index}=[B{CCCS(i).Node2,i+index} '-' CCCS(i).Value];
   end
   
   index=index+numCCCS;
    %Now handle the case of the Op Amp
    for i=1:numO,
        for j=1:numNode
            if (Opamp(i).Node3==j),
                B{j,i+index}='1';
            else
                B{j,i+index}='0';
            end
        end
    end
    %The B matrix is finished -------------------------------------------
    
    
    %Fill the C matrix ##################################################
    %Initially, fill with zeros.
    [C{:}]=deal('0');
    
    %First handle the case of the independent voltage sources.
    for i=1:numV,           %Go through each independent source.
        for j=1:numNode     %Go through each node.
            if (Vsource(i).Node1==j),       %If node is first node,
                C{i,j}='1';                 %then put '1' in the matrices.
            elseif (Vsource(i).Node2==j),   %If second node, put -1.
                C{i,j}='-1';
            end
        end
    end
    index=numV;
    %handle VCVS
    for i=1:numVCVS,           %Go through each independent source.
        if(VCVS(i).Node1~=0) C{i+index,VCVS(i).Node1}='1';end
        if(VCVS(i).Node2~=0) C{i+index,VCVS(i).Node2}='-1';end
        if(VCVS(i).Node3~=0) C{i+index,VCVS(i).Node3}=[C{i+index,VCVS(i).Node3} '-' VCVS(i).Name];end
        if(VCVS(i).Node4~=0) C{i+index,VCVS(i).Node4}=[C{i+index,VCVS(i).Node4} '+' VCVS(i).Name];end
    end
    index=index+numVCVS+numCCCS;
    %Now handle the case of the Op Amp
    for i=1:numO,
        for j=1:numNode
            if (Opamp(i).Node1==j),
                C{i+index,j}='1';
            elseif (Opamp(i).Node2==j),
                C{i+index,j}='-1';
            else
                C{i+index,j}='0';
            end
        end
    end
    %The C matrix is finished ------------------------------------------
    
    
    %Fill the D matrix ##################################################
    %The D matrix is non-zero only for CCVS and VCVS (not included
    %in this simple implementation of SPICE)
    [D{:}]=deal('0');
    
    %Do not support CCVS h NOW.
    
    %The D matrix is finished -------------------------------------------
    
    %Fill the E matrix ##################################################
    %Start with all zeros
    [E{:}]=deal('0');
    for i=1:numV,
        E{i}=Vsource(i).Name;
    end
    %The E matrix is finished -------------------------------------------
    
    %Fill the J matrix ##################################################
    for i=1:numV,
        J{i}=['I_' Vsource(i).Name];
    end
    index=numV;
    for i=1:numVCVS,
        J{i+index}=['I_' VCVS(i).Name];
    end
    index=index+numVCVS;
    for i=1:numCCCS,
     %   J{i+index}=['I_' CCCS(i).Name]; %is this right?
    end
    index=index+numCCCS;
    for i=1:numO,
        J{i+index}=['I_' Opamp(i).Name];
    end
    %The J matrix is finished -------------------------------------------
end  %if ((numV+numO)~=0)

%Form the A, X, and Z matrices (As cell arrays of strings).
if ((num2)~=0),
    Acell=[deal(G) deal(B); deal(C) deal(D)];
    Xcell=[deal(V); deal(J)];
    Zcell=[deal(I); deal(E)];
else
    Acell=[deal(G)];
    Xcell=[deal(V)];
    Zcell=[deal(I)];
end


%Declare symbolic variables #########################################
%This next section declares all variables used as symbolic variables.
%Make "s" a symbolic variable
SymString='syms s ';

%Add each of the passive elements to the list of symbolic variables.
for i=1:numElem,
    SymString=[SymString Element(i).Name ' '];
end
for i=1:numVCVS,
    SymString=[SymString VCVS(i).Name ' '];
end
for i=1:numVCCS,
    SymString=[SymString VCCS(i).Name ' '];
end
for i=1:numCCCS,
    SymString=[SymString CCCS(i).Name ' '];
end


%Add each element of matrix J and E to the list of symbolic variables.
for i=1:numV,
    SymString=[SymString J{i} ' '];
    SymString=[SymString E{i} ' '];
end
index=numV;
for i=1:numVCVS,
    SymString=[SymString J{i+index} ' '];
end
index=index+numVCVS;
for i=1:numCCCS,
    SymString=[SymString J{i+index} ' '];
end
index=index+numCCCS;
%Add each opamp output to the list of symbolic variables.
for i=1:numO,
    SymString=[SymString J{i+index} ' '];
end

%Add independent current sources to the list of symbolic variables.
for i=1:numI,
    SymString=[SymString Isource(i).Name ' '];
end

%Add independent voltage sources to list of symbolic variables.
for i=1:numNode,
    SymString=[SymString V{i} ' '];
end

%Evaluate the string with symbolic variables
eval(SymString);
%Done declaring symbolic variables ----------------------------------

%Create the variables A, X, and Z ###################################
%Right now the matrices Acell, Xcell and Zcell hold cell arrays of 
%strings.  These must be converted to a symbolic array.  This is
%accompplished by creating strings that represent the assignment of
%the symbolic arrays, and then evaluating these strings.

%Create assignments for three arrays
Astring='A=[';
Xstring='X=[';
Zstring='Z=[';

for i=1:length(Acell),     %for each row in the arrays.
    for j=1:length(Acell),      %for each column in matrix A.
        Astring=[Astring ' ' Acell{i,j}]; %Get element from Acell
    end
    Astring=[Astring ';'];          %Mark end of row with semicolon
    Xstring=[Xstring  Xcell{i} ';'];    %Enter element into array X;
    Zstring=[Zstring  Zcell{i} ';'];    %Enter element into array Z;
end
Astring=[Astring '];'];  %Close array assignment.
Xstring=[Xstring '];'];
Zstring=[Zstring '];'];

%Evaluate strings with array assignments.
eval([Astring ' ' Xstring ' ' Zstring])
%Done creating the variables A, X, and Z ----------------------------


%Solve matrrix equation - this is the meat of the algorithm.
V=simplify(inv(A)*Z);

%Evaluate each of the unknowns in the matrix X.
for i=1:length(V),
    eval([char(X(i)) '=' char(V(i)) ';']);
end

%Assign a numeric value to each passive element, if one is provided.
for i=1:numElem
    if ~isnan(Element(i).Value),
        eval([Element(i).Name '=' num2str(Element(i).Value)  ';']);
    end
end
for i=1:numVCVS
    if ~isnan(VCVS(i).Value),
        eval([VCVS(i).Name '=' num2str(VCVS(i).Value)  ';']);
    end
end
for i=1:numVCCS
    if ~isnan(VCCS(i).Value),
        eval([VCCS(i).Name '=' num2str(VCCS(i).Value)  ';']);
    end
end
for i=1:numCCCS
    if ~isnan(CCCS(i).Value),
        eval([CCCS(i).Name '=' num2str(CCCS(i).Value)  ';']);
    end
end
%Assign a numeric value to each voltage source, if one is provided.
for i=1:numV
    if ~isnan(Vsource(i).Value),
        eval([Vsource(i).Name '=' num2str(Vsource(i).Value)  ';']);
    end
end

%Assign a numeric value to each passive element, if one is provided.
for i=1:numI
    if ~isnan(Isource(i).Value),
        eval([Isource(i).Name '=' num2str(Isource(i).Value)  ';']);
    end
end

disp(sprintf('Done! Elapsed time = %g seconds.\n',toc));
disp(sprintf('Node num %d\n',nodecount));
disp('Netlist');
for i=1:size(Name),
    disp(sprintf(' %s %s  %s %s %s %s',Name{i},N1{i},N2{i},N3{i},N4{i},arg{i}));
end
disp(' ');
disp('Solved variables:');
disp(X)


% eval(v_x)
% collect(v_x,s)
% simplify(eval(v_x))
% [n,d]=numden(eval(v_x));
% mysys=tf(sym2poly(n),sym2poly(d));



