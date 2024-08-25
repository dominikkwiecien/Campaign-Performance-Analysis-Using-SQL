WITH CTE AS (
    SELECT 
        facebook_ads_basic_daily.ad_date,
        facebook_ads_basic_daily.url_parameters,
        COALESCE(facebook_ads_basic_daily.spend, 0) AS spend,
        COALESCE(facebook_ads_basic_daily.impressions, 0) AS impressions,
        COALESCE(facebook_ads_basic_daily.reach, 0) AS reach,
        COALESCE(facebook_ads_basic_daily.clicks, 0) AS clicks,
        COALESCE(facebook_ads_basic_daily.leads, 0) AS leads,
        COALESCE(facebook_ads_basic_daily.value, 0) AS value
    FROM 
        facebook_ads_basic_daily 
    JOIN 
        facebook_adset ON facebook_ads_basic_daily.adset_id = facebook_adset.adset_id
    JOIN 
        facebook_campaign ON facebook_ads_basic_daily.campaign_id = facebook_campaign.campaign_id
    JOIN 
        google_ads_basic_daily ON facebook_campaign.campaign_name = google_ads_basic_daily.campaign_name
)
SELECT 
    ad_date,
    CASE 
    	WHEN LOWER(SUBSTRING(url_parameters FROM 'utm_campaign=([^&]*)')) = 'nan' THEN NULL
    	ELSE LOWER(SUBSTRING(url_parameters FROM 'utm_campaign=([^&]*)'))
	END AS utm_campaign,
    SUM(spend) AS total_spend,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    SUM(value) AS total_value,
    CASE 
        WHEN SUM(impressions) = 0 THEN 0
        ELSE round(1.0 * SUM(clicks) / SUM(impressions), 2) * 100
    END AS CTR,
    CASE 
        WHEN SUM(clicks) = 0 THEN 0
        ELSE round(1.0 * SUM(spend) / SUM(clicks), 2)
    END AS CPC,
    CASE 
        WHEN SUM(impressions) = 0 THEN 0
        ELSE round(1.0 * SUM(spend) / SUM(impressions), 2) * 1000
    END AS CPM,
    CASE 
        WHEN SUM(spend) = 0 THEN 0
        ELSE round(1.0 * SUM(value) / SUM(spend), 2)
    END AS ROMI
FROM 
    CTE
GROUP BY 
    ad_date, utm_campaign
   
