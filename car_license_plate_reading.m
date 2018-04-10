%Yogesh Pawar
    clc;
    close all;
    clear all;
    
    f=imread('carplate2.jpg');
    f=imresize(f,[400 NaN]);  % Resizing the image keeping aspect ratio same ,NaN : If you set x to be 400 then y is modified proportionnally.  %%image loading unit
    
    imshow(f);
    % ---------------------------------------------------------------------
    
    g=rgb2gray(f);          % rgb2gray converts the truecolor image RGB to the grayscale.
    g=medfilt2(g,[3 3]);    % Median filtering is a nonlinear operation often used in image processing to reduce "salt and pepper" noise.
    conc=strel('disk',1);   % creates a disk-shaped structuring element
    gi=imdilate(g,conc);        % gi = imdilate(g,conc) dilates the grayscale, binary, or packed binary image g, returning the dilated image, gi.
    ge=imerode(g,conc);         %  gi = imdilate(g,conc) erodes the grayscale, binary, or packed binary image g, returning the eroded image, gi.   %%%% morphological image processing
    gdiff=imsubtract(gi,ge);    % Z = imsubtract(X,Y) subtracts each element in array Y from the corresponding element in array X and returns the difference in the corresponding element of the output array Z.
    gdiff=mat2gray(gdiff);      % sets the values of amin and amax to the minimum and maximum values in A.
    gdiff=conv2(gdiff,[1 1;1 1]);
    gdiff=imadjust(gdiff,[0.5 0.7],[0 1],.1);   %  increases the contrast of the output image J.
                                                %J = imadjust(I,[low_in; high_in],[low_out; high_out]) maps the values in I to new values in J such that values between low_in and high_in map to values between low_out and high_out.                              
    B=logical(gdiff);       % Any nonzero element of A is converted to logical 1 (true) and zeros are converted to logical 0 (false).
    [a1 b1]=size(B);
    
    figure(2) 
    imshow(B)
    %----------------------------------------------------------------------
    
    er=imerode(B,strel('line',100,0)); % A strel object represents a flat morphological structuring element, which is an essential part of 
                                            % morphological dilation and erosion operations  
    figure(3)
    imshow(er)
    %----------------------------------------------------------------------
    
    out1=imsubtract(B,er);
    F=imfill(out1,'holes');     % performs a flood-fill operation on background pixels of the input binary image         %%%filling the object
    H=bwmorph(F,'thin',1);      % With n = Inf, thins objects to lines. It removes pixels so that an object without holes shrinks to a minimally 
                                % connected stroke, and an object with holes shrinks to a connected ring halfway between each hole and the outer boundary. 
                                 % This option preserves the Euler number.
    H=imerode(H,strel('line',3,90));
   
    figure(4)
    imshow(H)
    %----------------------------------------------------------------------
    
    final=bwareaopen(H,floor((a1/15)*(b1/15))); % removes from a binary image all connected components (objects) that have fewer than P pixels 
    final(1:floor(.9*a1),1:2)=1;
    final(a1:-1:(a1-20),b1:-1:(b1-2))=1;
    yyy=template(2);    % In the Template file box, select a file name and location for the template SLTX file. Tip Save the template on the MATLAB® path 
                            % to make it visible in the Simulink start page. 
    
    figure(5)
    imshow(final)
    %----------------------------------------------------------------------
    
    Iprops=regionprops(final,'BoundingBox','Image'); % BoundingBox :: Returns the smallest rectangle containing the region, specified as a 1-by-Q*2 vector, where Q is 
                                                       % the number of image dimensions
    %   The hold function determines whether new graphics objects are added to the graph or replace objects in the graph.
    hold on
    %    hold on retains the current plot and certain axes properties so that subsequent graphing commands add to the existing graph.
    for n=1:size(Iprops,1)
        rectangle('Position',Iprops(n).BoundingBox,'EdgeColor','g','LineWidth',2); %Draw a rectangle and specify the fill color, outline color, and outline width.
    end 
    hold off
    %   hold off resets axes properties to their defaults before drawing new plots. hold off is the default.
    NR=cat(1,Iprops.BoundingBox);   %%  Data storage section % Concatenate arrays along specified dimension
    [r ttb]=connn(NR);

    if ~isempty(r)


        xlow=floor(min(reshape(ttb(:,1),1,[])));
        xhigh=ceil(max(reshape(ttb(:,1),1,[])));
        xadd=ceil(ttb(size(ttb,1),3));
        ylow=floor(min(reshape(ttb(:,2),1,[])));    %%%%%area selection
        yadd=ceil(max(reshape(ttb(:,4),1,[])));
        final1=H(ylow:(ylow+yadd+(floor(max(reshape(ttb(:,2),1,[])))-ylow)),xlow:(xhigh+xadd));
        [a2 b2]=size(final1);
        final1=bwareaopen(final1,floor((a2/20)*(b2/20)));
        
        figure(6)
        imshow(final1)
    %----------------------------------------------------------------------

        Iprops1=regionprops(final1,'BoundingBox','Image');
        NR3=cat(1,Iprops1.BoundingBox);
        I1={Iprops1.Image};

        %%
        carnum=[];
        if (size(NR3,1)>size(ttb,1))
            [r2 to]=connn2(NR3);

            for i=1:size(Iprops1,1)

                ff=find(i==r2);
                if ~isempty(ff)
                    N1=I1{1,i};
                    letter=readLetter(N1,2);
                else
                    N1=I1{1,i};
                    letter=readLetter(N1,1);
                end
                if ~isempty(letter)
                    carnum=[carnum letter];
                end
            end
        else
            for i=1:size(Iprops1,1)
                N1=I1{1,i};
                letter=readLetter(N1,1);
                carnum=[carnum letter];
            end
        end
        %%

        fid1 = fopen('carnum.txt', 'wt');
        fprintf(fid1,'%s',carnum);
        fclose(fid1);
        winopen('carnum.txt')



    else
        fprintf('license plate recognition failure\n');
        fprintf('Characters are not clear \n');
    end