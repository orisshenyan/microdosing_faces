# Pareidolia experiment #
This repository contains data and a pipeline for analysing data for a pareidolia experiment.

This experiment  consists of a training experiment and a main experiment. The data for this is stored into Pilot_Data, while the pipeline to analyse it is stored in Piloting_v4.rmd.

The instructions given to participants are as follows:

**Training**
> The training phase will last approximately 15 minutes. Your job is to look for difficult-to-see faces that could appear at various locations, sizes, and contrasts. Faces will be shown in moving noise for four-second intervals. Within a trial, there is always a face. After each four-second interval, you will have three seconds to decide whether the face appeared on the right or the left side of the screen. You should indicate this via your keyboard: Use the left arrow key if you believe the face is on the left. Use the right arrow key if you believe the face is on the right. If you are unsure or did not see a face, you should guess which direction it was in. Please try and answer quickly.  
Please try and avoid the escape key. If you press the escape key, the experiment will crash and you may have to repeat some sections.  
After each decision, a confidence rating screen will appear. Rate your confidence in your perception of the face on a scale of 1 to 4, using the number keys 1 through 4 to indicate your confidence.  
1: You did not see a face.  
2: You are not confident in your decision.  
3: You are somewhat confident.  
4: You distinctly saw a face.  
You will have three seconds to provide your confidence rating.  
You are not expected to read the instructions on the decision screen each time; just remember these mappings. You will complete 20 trials, divided into seven blocks (140 trials in total). You can take breaks between the blocks.
We will first do a practise session so you understand how the task works.  
(set parameters, subject to ‘practise’; blocks to 1; trials to 5)

**Main experiment**
>The main experiment will last approximately 50 minutes. It consists of seven blocks, with the opportunity for breaks between blocks. The experiment will consist of continuous noise for about five and a half minutes per block. Your task is to press the number 1 whenever you perceive a face in the noise. After pressing the number 1, the confidence rating screen will appear as in the training phase. Rate your confidence in your perception of the face on the same 1–4 scale. You will have three seconds to provide your confidence rating.  
There are quite a few faces hidden - you should press when you see face even if you are not sure.  The faces will be very difficult to perceive. You should try not to miss any faces when there is a face. You are encouraged to focus on your task and give your best effort. You are free to take breaks between blocks as needed.  
We will first do a practise session so you understand how the task works.  
(set parameters, subject to ‘practise’; blocks to 1; trials to 10)


## Training ##
The training experiment consists of 6 blocks of twenty trials, though in normal circumstances there would be 7. The files consisting of the training data are in /Pilot_data and end in 'trainingblock001.csv' through to 'trainingblock006.csv'. 'trainingblock000' is missing for this participant. 

A trial consists of  4 seconds of dynamic noise. Within this noise, a face is displayed somewhere in the periphery, on the right or on the left, at an opacity varying from 10% to 70%, going up in 10% increments. The faces also vary in size from 6 to 9 degrees of visual angle. 
After the 4 seconds of noise, participants have 3 seconds to respond whether the face was on the right or left. They then report their confidence in their decision on a scale from 1 to 4. 

![image](https://github.com/user-attachments/assets/6e256a53-9081-4063-b81b-0c2530720c57)


The data is organised as follows:

| Face_response | Face_confidence | Face_Onset_Time        | Face_Position | Noise_Number | Face_Size | Opacity | Direction_Report |
|--------------|----------------|------------------------|--------------|-------------|-----------|---------|-----------------|


'Face_response' shows whether there is a face in a trial or not, and as in the training there is a face in every trial, this is always set to 1. 'Face_confidence' indicates confidence of the the participants decision from 1-4. 'Face_Onset_Time' indicates when in the block the face was shown. 'Face_Position' indicates whether the face was shown on the left (negative numbers) or on the right (positive numbers). 'Face_Size' indicates the size of the face, from 6 to 9 degrees of visual angle. 'Opacity' indicates the opacity of the face, from 0.1 (10%) to 0.7 (70%), in 10% increments. 'Direction_Report' shows whether participants reported the face as being on the left or the right, where '1' indicating the participant pressed the left button and '2' indicating the participant pressed the right button. 

## Training ##
The main experiment consists of 7 blocks of 120, 2.5 second trials, displayed back to back with no break, creating the illusion of continuous noise to the participant. Within the continuous noise, there are faces shown on 30 of the trials, beginning at an opacity of 25%. Again, faces can appear on the periphery on the left or the right, and can appear at 6 to 9 degrees of visual angle. Participants will press a button to indicate when they have seen a face, and after that will be asked for metacognitive judgements about their decision. The files for the main experiment are in /Pilot_data and end in 'tmainblock001.csv' through to 'mainblock006.csv'.
![image](https://github.com/user-attachments/assets/8c7b1816-3e0d-4f05-b169-e14942827368)
This opacity of true faces increases after every block only if participants view >90% of true faces (where opacity decreases by 1%), or <10% of true faces, (where opacity increases by 1%.). The opacity for each block is in the file ending in 'final_opac.csv'. 

| Realface_response | Realface_confidence | Realface_Image_Onset_Time | RealFace_Image_Response_Time | Hallucination_response | Hallucination_confidence | Noise_Onset_Time       | Hallucination_Response_Time | ConfidenceScreen_Onset | Face_Position | Noise_Number | Face_Size |
|------------------|--------------------|--------------------------|-----------------------------|----------------------|----------------------|---------------------|----------------------|----------------------|--------------|-------------|-----------|

There should be 120 rows, as there is 120 trials. 

Column 'Realface_response' can take the form of the numbers '80', '0' or '1'. If a trial was a trial in which a real face was **not** shown, then this column will be set to 80. This will be the case in 90 out of the 120 trials per block. If a real face was shown, this column will show **0** if the face was not detected by the participant, and **1** if the face was detected by the participant. Similarily, 'Realface_confidence' will also display 80 on trials where faces were not shown; or will be blank if no face was detecetd or the participant did not respond to the prompt, or will be set to the confidence recorded (1-4) if the participant responded. 'Realface_Image_Onset_Time' will show the time in the block where the face in th was shown and	'RealFace_Image_Response_Time' will show the time that the participant responded to the face, if they did respond to the face. 

The column 'Hallucination_response' can take the form of the numbers '90', '0' or '1'. If a trial was a trial in which a real face was **not** shown, then this column will be set to 0 or 1, depending on whether a hallucination was reported during the trial (1) or not (0). This will be the case in 90 out of the 120 trials per block. If a real face was shown, this column will show **90**. Similarily, 'Hallucination_confidence' will also show on the 90 trials where real faces were not shown the confidence (1-4) if the participant indicated that they had seen a face. Column 'Hallucination_Response_Time' will show when in the trial someone perceived a false face. Column 'ConfidenceScreen_Onset' shows when the the confidence screen is shown after a participant indicates a response, regardless of whether there was a true face or not.

Columns 'Noise_Onset_Time' and 'Noise_Number' show one noise number at each timestamp for each trial. Finally, column 'Face_Size' shows the size of the face, from 6 to 9 degrees of visual angle and 'Face_Position' shows where on the screen the face was shown in units of visual angle. On both of these columns, if this value is blank it is because it is not a trial where a face is shown.


