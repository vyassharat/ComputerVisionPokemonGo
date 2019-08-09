function [ID, CP, HP, stardust, level, cir_center] = pokemon_stats (img, model)
% Please DO NOT change the interface
% INPUT: image; model(a struct that contains your classification model, detector, template, etc.)
% OUTPUT: ID(pokemon id, 1-201); level(the position(x,y) of the white dot in the semi circle); cir_center(the position(x,y) of the center of the semi circle)
try
    imgSize=size(img);
    imgToClassify = imcrop(imresize(img, [1100,600]), [150,164,330,315]);
    %img = imresize(img, [1650,1200]);
    imgOcr = ocr(img);

    try
      [centers,radii] = imfindcircles(rgb2gray(img),[10 30],'ObjectPolarity','bright','Sensitivity',0.92);
      centers=centers(centers(:,1)>imgSize(2)*.3 & centers(:,1)<imgSize(2)*.6 & centers(:,2)<imgSize(1)*0.25 & centers(:,2)>imgSize(1)*.1,:);
      finalLevel=centers(1,:);
    catch
      finalLevel = [imgSize(2)/2 imgSize(1)/6];
    end

    hpTopLeft = [500 1050];
    hpOffset = [230 50];

    sdTopLeft = [230 1200];
    sdOffset = [270 169];


    % Replace these with your code
    %cpOcr = ocr(imcrop(rgb2gray(img),[cpTopLeft(1),cpTopLeft(2),cpOffset(1),cpOffset(2)]));
    % hpOcr = ocr(imcrop(rgb2gray(img),[hpTopLeft(1),hpTopLeft(2),hpOffset(1),hpOffset(2)]));
    %stardustOcr = ocr(imcrop(rgb2gray(img),[sdTopLeft(1),sdTopLeft(2),sdOffset(1),sdOffset(2)]));

    %Use cnn to classify pokemon and get id
    classifiedID=classify(model.net,imgToClassify);
    ID = str2double(string(classifiedID(1)));

    %%CP%%%%%%%%%%%%%%%%%%%%%%%%%
    try
        cpOcr = ocr(imcrop(histeq(rgb2gray(img),2),[imgSize(2)*.16,imgSize(1)*.02,imgSize(2)*.6,imgSize(1)*.12]));
        if(contains(lower(cpOcr.Text),'cp'))
            powerInd = strfind(lower(cpOcr.Text),lower('cp'));
            orgStr = extractBetween(cpOcr.Text,powerInd,length(cpOcr.Text));
            orgStr=regexprep(orgStr,'[\n\r]+','')
            orgStr=strrep(lower(orgStr),'o','0');
            orgStr=(strrep(lower(orgStr),'z','2'));
            orgStr=(strrep(lower(orgStr),'i','1'));
            orgStr=(strrep(lower(orgStr),'l','1'));
            orgStr = regexpi(string(orgStr(1)),'(\d{1,9})','match');
            val = str2double(orgStr(1));
            if(isempty(orgStr))
                CP=130;
            else
                 CP=val;
            end
        else
            CP=130;
        end
    catch
        CP=130;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %%HP%%%%
    try
    hpOcr = ocr(imcrop(imsharpen(img,'Amount',3),[imgSize(1)*.1,imgSize(2)*.4,imgSize(2)*.7,imgSize(1)*.4]));
    if(contains(hpOcr.Text,'HP'))
        orgStr = erase(hpOcr.Text,' ');
        orgStr = regexpi(orgStr,'(\d*)\/','match');
        arr=str2double(erase(orgStr,'/'));
        validInd = find(~isnan(arr), 1);
        HP = arr(validInd);
    else
        hpText = hpOcr.Words(3);
        hpText = strrep(hpText,'HP','');
        if(contains(hpText,'/'))
            HP = str2double(extractBefore(hpText,"/"));
        else
            HP = str2double(strtrim(hpText));
        end
    end
    catch
    HP=100;    
    end

    if(isempty(HP))
        HP=100;
    end
    %%%%%%%%

    %%STARDUST%%%%%%%%%%%%%%%%%%%
    try
      stardustOcr =  ocr(imcrop(imsharpen(img,'Amount',3),[imgSize(2)*.13,imgSize(1)*.71,imgSize(2)*.54,imgSize(1)*.17]));
      if(contains(stardustOcr.Text,'pow','IgnoreCase',true))
            powerInd = strfind(lower(stardustOcr.Text),lower('pow'));
            orgStr = extractBetween(stardustOcr.Text,powerInd,length(stardustOcr.Text));
            orgStr=regexprep(orgStr,'[\n\r]+','');
            orgStr = regexpi(string(orgStr(1)),'(\d{1,9})','match');
            val = str2double(orgStr(1));
            if(isempty(orgStr))
                stardust=600;
            else
                 stardust=val;
            end
        elseif(contains(imgOcr.Text,'pow','IgnoreCase',true))
            powerInd = strfind(lower(imgOcr.Text),lower('pow'));
            imgOrgStr = extractBetween(imgOcr.Text,powerInd,length(imgOcr.Text));
            imgOrgStr = regexprep(imgOrgStr,'[\n\r]+','');
            imgOrgStr = regexpi(string(imgOrgStr(1)),'(\d{1,9})','match');
            val = str2double(imgOrgStr(1));
            if(isempty(imgOrgStr))
                stardust=600;
            else
                 stardust=val;
            end
        else
            stardust=600;
        end
    catch
        stardust=600;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    level = [finalLevel(1),finalLevel(2)];
    cir_center = [355,457];
catch
    ID = 1;
    CP = 123;
    HP = 26;
    stardust = 600;
    level = [327,165];
    cir_center = [355,457];
end
end