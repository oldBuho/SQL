-- loaded this in the "oracle" enviroment
with not_null_subm as (
select  submission_date, hacker_id, count(submission_id) as subm_count_per_user
from Submissions
group by submission_date, hacker_id
having count(submission_id) >= 1
order by submission_date),
maxUserDaily as (
select submission_date, max(subm_count_per_user) max_of_the_day
from not_null_subm
group by submission_date),
user_daily_more_subm as (
select s.submission_date, MIN(s.hacker_id) hacker_id
from not_null_subm s
inner join maxUserDaily m
on s.submission_date = m.submission_date
where subm_count_per_user = max_of_the_day 
GROUP BY s.submission_date, m.max_of_the_day),  
subm_day_count as (
select submission_date, hacker_id, subm_count_per_user,  count(submission_date) over (partition by hacker_id order by submission_date) days_in_a_row
from not_null_subm
order by hacker_id, submission_date),
accum_day_counters as (
select s.submission_date, 
s.submission_date - min(m.min_date) + 1 accum_day_counter
from Submissions s
cross join (select min(submission_date) min_date from Submissions)  m
group by s.submission_date
order by s.submission_date),
pre_final as (
select sdc.submission_date, sdc.days_in_a_row
from subm_day_count sdc 
left join accum_day_counters adc
on sdc.submission_date = adc.submission_date 
where sdc.days_in_a_row = adc.accum_day_counter
order by sdc.submission_date, sdc.hacker_id),
numb_users_in_a_row as (
select submission_date, count(days_in_a_row) num_days_in_a_row from pre_final group by submission_date),
pre_final_table as (
select n.submission_date, n.num_days_in_a_row, u.hacker_id 
from numb_users_in_a_row n
left join user_daily_more_subm u
on n.submission_date = u.submission_date), 
final_table as (
select t.submission_date, t.num_days_in_a_row, t.hacker_id,  h.name
from pre_final_table t
inner join Hackers h
on t.hacker_id = h.hacker_id)
select * from final_table order by submission_date;