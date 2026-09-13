# diabetes-Ordinal-LR-SAS
biostatistical analysis of a synthetic diabetes dataset using ordinal logistic regression in SAS

# Diabetes Risk Analysis Using Ordinal Logistic Regression in SAS

## Research Question

** Which demographic, anthropometric, clinical, and lifestyle factors are associated with higher odds of being in a more severe
    HbA1c-defined glycemic status category (normal → prediabetes → diabetes)?**

## Dataset Note

This analysis uses an AI-generated synthetic diabetes dataset obtained from Kaggle. 
The dataset was used to demonstrate an applied biostatistical workflow in SAS, 
including data exploration, descriptive analysis, ordinal logistic regression, 
assessment of model assumptions, missing-data evaluation, and sensitivity analysis.

Results should not be interpreted as estimates of real-world clinical or population-level associations.

## Outcome

The primary outcome was **Glycemic_Status**, which was created using HbA1c values:
- **Normal:** HbA1c < 5.7%
- **Prediabetes:** HbA1c 5.7% to < 6.5%
- **Diabetes:** HbA1c ≥ 6.5%

## Variables Included in the Analysis
The adjusted ordinal logistic regression included the following predictors:

**Demographic Variables:**  
Age, Gender, Residence Type

**Lifestyle Variables:**  
Exercise_Hours_Per_Week, Daily_Walking_Minutes, Sleep_Hours, Diet_Quality, Smoking_Status, Alcohol_Consumption

**Clinical and Anthropometric Variables:**  
BMI, Waist_Circumference, Systolic_Blood_Pressure, Diastolic_Blood_Pressure, HDL, LDL, Triglycerides, Heart_Rate, 
Family_History_of_Diabetes, Hypertension, Heart_Disease, Fatty_Liver

## Variables Excluded from the Primary Model

**HbA1c:** Used to define the Glycemic_Status outcome.
**Blood_Glucose and Fasting_Blood_Sugar:** Direct measures of glycemia and closely related to the outcome.
**Height, Weight, and BMI_Category:** Continuous BMI was already included in the model.
**Diabetes_Risk_Score:** May incorporate information from several predictors already included in the analysis.
**Insulin_Level:** Closely related to insulin resistance and glycemia.
**Total_Cholesterol:** HDL, LDL, and triglycerides provide more specific lipid measurements.
**Daily_Water_Intake:** Has a weaker direct relationship with the primary research question.

## Methods
All analyses were conducted using SAS. Glycemic status was treated as an ordinal outcome with three ordered categories: Normal, Prediabetes, and Diabetes. 
Glycemic status was defined using HbA1c values, with HbA1c < 5.7% classified as Normal, 5.7% to < 6.5% as Prediabetes, and ≥ 6.5% as Diabetes.
Continuous variables were summarized within each glycemic-status group using the mean, standard deviation, median, interquartile range, minimum, and maximum.
Differences in continuous variables across glycemic-status groups were evaluated using one-way ANOVA. 
Tukey-adjusted comparisons were used for pairwise group comparisons, and Levene’s test was used to assess homogeneity of variance. 
Categorical variables were summarized using frequencies and compared across glycemic-status groups using chi-square tests.

Pearson correlations were calculated among continuous predictors to assess potential redundancy. 
Predictor pairs with an absolute correlation of at least 0.70 were flagged as potentially redundant. 
The magnitude of the correlation rather than its p-value was used for this screening because the large sample size 
could result in statistically significant p-values even for weak correlations.

Unadjusted ordinal logistic regression models were first fit separately for predictors to estimate their individual 
associations with glycemic status. Models were specified so that odds ratios greater than 1 represented higher odds of being in a more severe glycemic-status category. 
Categorical predictors were modeled using specified reference categories.

A multivariable ordinal logistic regression model was then fit to estimate adjusted associations between the selected 
demographic, lifestyle, anthropometric, and clinical predictors and glycemic status. The adjusted model included age, BMI, 
waist circumference, systolic and diastolic blood pressure, exercise hours per week, daily walking minutes, sleep hours, 
LDL, HDL, triglycerides, heart rate, gender, diet quality, smoking status, alcohol consumption, family history of diabetes,
hypertension, heart disease, fatty liver, and residence type. Adjusted odds ratios, 95% confidence intervals, and 
p-values were used to evaluate associations after accounting for the other variables in the model.

Missing data were assessed for variables included in the primary analysis. A complete-case indicator was created to identify 
observations with complete information across the outcome and selected predictors, and complete and incomplete observations 
were compared descriptively. The adjusted regression model used observations with complete data for all variables included in the model.

The proportional-odds assumption was assessed using the score test. A nonsignificant result was interpreted as no evidence 
that the proportional-odds assumption was violated, supporting the use of the ordinal logistic regression model. In the final adjusted model,
the score test was nonsignificant (χ² = 17.46, df = 25, p = 0.864).

Finally, a sensitivity analysis was conducted to examine potential overlap between BMI and waist circumference. 
The primary model containing both measures was compared with a model containing BMI but excluding waist circumference 
and a second model containing waist circumference but excluding BMI.

## Results

The synthetic dataset contained 50,000 observations. Of the full dataset, 14.0% were classified as normal, 9.54% as prediabetes, 72.51% as diabetes, and 
3.95% had missing glycemic status. The final complete-case adjusted model included 39,601 observations.

Descriptive comparisons showed little evidence of meaningful differences across glycemic-status groups for most 
demographic, clinical, anthropometric, and lifestyle variables. In unadjusted ordinal logistic regression, most predictors were not statistically significant; 
LDL showed a small positive association with worsening glycemic status (OR = 1.001, p = 0.020).

In the adjusted model, the proportional-odds test showed no evidence of violation (p = 0.864).
The overall model was not statistically significant (Likelihood Ratio χ²(25) = 28.99, p = 0.264)
and had very low explanatory power (R² = 0.0007). Diastolic blood pressure (p = 0.049) and LDL (p = 0.046) 
reached the conventional significance threshold, but their estimated effect sizes were extremely small.
Sensitivity analyses using BMI and waist circumference separately produced similar results and did not materially change the overall conclusions.

## Discussion

The main takeaway from this analysis is that statistical significance alone would have been a poor way to judge the usefulness of the model. 
Although LDL and diastolic blood pressure crossed the p < 0.05 threshold after adjustment, their estimated effects were extremely small, 
while the overall model explained almost none of the variation in glycemic status.

The results also changed very little when BMI and waist circumference were modeled separately, 
suggesting that the weak overall model performance was not driven by the choice between these two adiposity measures.
Because the data are AI-generated, the lack of strong associations should not be interpreted as evidence that these factors are unimportant in real populations. 
Instead, the analysis highlights the importance of evaluating effect size, model fit, assumptions, and sensitivity analyses rather than focusing only on p-values.

## Conclusion

This analysis was originally conducted before I realized that the dataset was AI-generated. 
After learning that the data were synthetic, I reframed the project as a demonstration of my SAS programming and applied biostatistical 
workflow rather than as a source of real-world clinical conclusions.
The project strengthened my experience with data exploration, descriptive analysis, ordinal logistic regression, model diagnostics,
missing-data assessment, and sensitivity analysis. I would like to apply a similar workflow to a real clinical or public health dataset, 
where the resulting associations could be evaluated in a meaningful real-world context.

