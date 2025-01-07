# Analyzing Rate Competitiveness Project: Harnessing Loding Data to Enable Informed Decision-making

**Hi there! Here is my project contribution in a nutshell:**

In this project during my internship at a global travel technology company, I delved into previously underutilized lodging data to build scalable queries in GCP using BigQuery, visualize results using Python, and present results to a key corporate client. My analysis provided value to the client by enabling them to evaluate the effectiveness of their negotiated rate program in order to identify potential cost savings opportunities. My efforts pioneered a new category of revenue for the company and enabled the company to fulfill pressing customer requests for travel program intelligence.

**If you're short on time,and feel free to directly view examples of my skills in this project:**

- SQL - several [queries](SQL-prep.sql) I developed using aggregations, joins, and case statements to transform data for visualization.
- Python - [visualizations](#gathering-data) I created using the Python libraries pandas, matplotlib, and seaborn.
- Stakeholder Communication - sample of how I would distill insights to an [executive](#executive-summary) audience vs. explaining the process to a [technical](#approach) audience.

**If you'd like to dig deeper into my work on this project, feel free to navigate by section:**

- [Project Background](#project-background)
- [Executive Summary](#executive-summary)
- [Approach](#approach)
- [Gathering Data](#gathering-data)
- [Findings](#findings)
- [Challenges](#challenges)
- [Learnings](#learnings)

## Project Background
At the company where interned, a major client had been eager to evaluate the effectiveness of their negotiated rate program in order to identify potential cost savings opportunities. 

Note: To maintain confiendentiality, I'll use "Company G" as a generic name for this corporate client and "GGG" as a generic name for the client's negotiated rate code, neither of which are indicative of any specific company. 

Managers from Company G suspected that its corporate travellers were possibly booking outside of Company G's negotiated offerings with certain hotel brands because public, TMC-sourced, or other rates may be lower cost or more available. In short, Company G wanted know what corporate travelers are shopping, seeing in responses, and what they are booking. 

## Executive Summary
- **Findings:** Company G's negotiated rate program for the given 1 month timeframe is effective and competitive, since the majority of searches and bookings result in Company G's negotiated rates and GGG rates were all found to be, on average, 26% below public rates. When leakage occurs, GGG rates are still lower cost than the average of other rates, so corporate travelers may not be selecting stays based on price alone. 
- **Recommendations:** Applying this rate competitiveness analysis approach to Company G for a longer timeline, such as 6-12 months can give client a more complete picture on their rate competitiveness program. Consider offering this analysis as a "Data-as-a-Service" and speak with finance and pricing teams on opportunity.

## Approach
In the analysis, I wanted to answered the question: When corporate travelers are making bookings not using their corporate rate code, is it because of:
- availability (corporate rates are not returned from their search results for whatever reason)
- Cost (other rates are lower cost)
- Or both?

There are 3 cases we wanted to measure:
1. In Case 1, where a GGG rate code was shopped and returned, and an GGG rate was price checked.
2. In Case 2, where a GGG rate code was shopped and returned, but another rate was price checked,
3. In Case 3, where a GGG rate code was shopped, but didn’t return, so another rate was price checked.

### Approach to Investigating Leakage
Case 2 is the “leakage” case, where a GGG rate code should have been price checked, but instead, the user clicked on another rate.

For those searches belonging to case 2, we wanted to find out if they were selecting that other rate based on cost or another factor. In other words, is GGG’s rate higher cost than other rates sometimes? I needed to analyze the percent difference between the average GGG rate and average non-GGG rate. My reasoning for interpretation was as follows:
- If the average GGG rate is a higher cost than non-GGG rates in this Case 2 leakage scenario, then the percent difference between the average GGG rate and the average non-GGG rate will be positive, that the GGG rate is a certain positive percentage more costly on average to the other rate.
- If the average GGG rate was a lower cost, then the percent difference between the average GGG rate and average non-GGG rate would be negative, then the GGG rate is a certain percentage below the other rate.

## Gathering Data
Because extracting this specific profile of data from Sabre's databases had not been done before, I learned a great deal from just the process of extracting the data itself (see sections on [Challenges](#challenges) and [Learnings](#learnings)). 

[Here](SQL-prep.sql) are anonymized samples of queries I developed to extract data from multiple sources, including the Google Cloud Platform and a legacy database. 

For the month of May 2024, I gathered all searches that were looking for GGG rates – 53,210. Next, I found that 84% of searches for GGG rates returned with GGG rates, while 16% of searches were not returned with an GGG rate. That 84% corresponded with case A and B, where an GGG rate was shopped and returned, and the 16% corresponded to case C, where an GGG rate didn’t return.
<img width="573" alt="Screen Shot 2025-01-06 at 3 02 47 PM" src="https://github.com/user-attachments/assets/64ff25c3-b136-49cf-9503-96b9d31af502" />

So now the next question is: what did these shoppers price check? What were they about to book?

As you might expect, if an GGG rate was returned, corporate travellers tended to price check it. But a small sliver of Company G searches where an GGG rate was returned actually price checked another rate.

<img width="922" alt="Screen Shot 2025-01-06 at 11 29 15 AM" src="https://github.com/user-attachments/assets/c6fe7a8e-dd0f-4108-a1dd-60b5a973e757" />

This small sliver is the Case 2, the leakage case that we were interested in analyzing further. (0.6% leakage)

While seeing this percent different for one search at a time could be useful, I found that seeing a distribution of these percentages for 254 searches would be most revealing. How do percent differences for average and minimum GGG rates compare to other rates over a sample of 254 searches?

**Here is what I found:**

Overall, the distribution of % differences between the average GGG and non-GGG rates were skewed mostly negative across the 254 case 2 search results.

When visualizing the results as a violin plot, we see that the wider sections of the violin plot represent a higher probability that members in the sample will take on a given value, the narrower sections represent a lower probability.

So here, the widest part of the violin plot is less than 0, which leads us to believe that there’s a higher probability for Price Checks in this sample to have a negative percentage difference compared to the average non-GGG rate.

<img width="599" alt="Screen Shot 2025-01-06 at 3 10 07 PM" src="https://github.com/user-attachments/assets/cc211e8d-e194-419d-a5d4-1a68a5d9f7cc" />

In this violin plot, the white dot represents the median, and the thick gray bar in the center represents the interquartile range. The thin gray line represents the rest of the distribution except for the points determined to be outliers.


## Findings
Company G's negotiated rate program for the given 1 month timeframe is effective and competitive, since the majority of searches and bookings result in Company G's negotiated rates and GGG rates were all found to be, on average, 26% below public rates. Leakage occurs at a negligible rate for the given timeframe, however applying this approach to several months will provide a more complete picture. 

## Challenges
- **Analyzing Data from an Unfamiliar Industry:** Since I had never worked in the travel industry before, I initially lacked context for the data I was pulling. Feedback on my extracts helped me realize I was unsure of expected data values and volumes, so I learned to "sense-check" my work by consulting team members on appropriate filters and field meanings.
- **Encountering Data Availability Issues:** While working on data extracts, I noticed an unexpectedly low volume of bookings, which turned out to be caused by a broader API connection issue. While other teams resolved the API problem, I pivoted to testing my approach on another company, allowing me to refine a generalizable method for data extraction and analysis.
- **Navigating Unclear Expectations:** At the start of the project, I asked questions to narrow down data requirements, but unclear client expectations made it challenging. I learned to take the initiative in gathering requirements and took an iterative approach, offering the best possible extracts to keep the project moving despite ambiguity.

## Learnings
- **I learned to ask often: how can I do this process better?** After making independent efforts to gather documentation, previously used  queries, and basic knowledge from meetings I set up with other team members, I realized the value of also directly discussing my thought process with team members. A key conversation with a data engineer helped me understand why I was struggling to query a 55TB nested table, leading me to refine my approach for precise and efficient data retrieval.
- **I also learned to ask myself frequently: why can I trust my numbers?** In  other words, what am I benchmarking these numbers against? Without industry experience, I needed an independent benchmark to validate my queries. My manager directed me to a trusted departmental dashboard, which I used regularly to verify that my data aligned with expected trends.
- **Lastly, I learned to take an active role in clarifying the ask.** Recognizing the project's complexity, I created a working requirements document to clearly define goals and assumptions. This document facilitated productive discussions on data sources, access, and the best approach for our team.
