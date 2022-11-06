-- Check duplicates
select a.*
from nouns a
join (
    select lemma, count(*)
    from nouns
    group by lemma
    having count(*) > 1
) b
on a.lemma = b.lemma;


-- Find characters number in each word
select lemma, length(lemma) chars_num
from nouns
order by chars_num  desc;

-- Clustering words by Letters
select
    substring(lemma, 1, 1) letter,
    lemma,
    length(lemma) chars_num
from nouns
order by letter, chars_num desc;

-- Cumulative distribution
select
    substring(lemma, 1, 1) letter,
    count(*) count,
    round(cume_dist() over (order by count(*))::numeric * 100, 2) as cume_dist_percentage
from nouns
group by letter;

-- How many words start with particular letter
select
    substring(lemma, 1, 1) letter,
    count(*) count
from nouns
group by letter
order by count desc;

-- Rank words by characters number in Letter-group
select
    letter,
    lemma,
    len
from (
        select
            lemma,
            substring(lemma, 1, 1) letter,
            length(lemma) len,
            dense_rank()
                over (partition by substring(lemma, 1, 1)
                    order by length(lemma) desc)
                as word_rank
        from nouns
     ) as word_rank
where word_rank = 1
order by len desc;

-- Longest(/Shortest) in a letter group
select
    n.lemma,
    length(n.lemma) len,
    substring(n.lemma, 1, 1) letter_n
from nouns n
inner join (
    select
        substring(lemma, 1, 1) letter,
        max(length(lemma)) max
    from nouns
    group by letter
) s on substring(n.lemma, 1, 1) = s.letter and length(n.lemma) = s.max
order by len desc;

-- Average chars number in a letter group
select
    substring(lemma, 1, 1) letter,
    avg(length(lemma)) avg
from nouns
group by letter;

-- Average chars number in a whole dict
select
    avg(length(lemma)) avg
from nouns;

-- Word 10 words after the longest word
select
    lemma,
    row_number
from (
    select
        lemma,
        row_number() over () row_number
    from nouns
     ) as sub
where sub.row_number = (
    select
       row_number
    from (
        select
            lemma,
            max(length(lemma)) over () max,
            length(lemma),
            row_number() over () row_number
        from nouns
        ) as sub
        where length(lemma) = max
    ) + 10;

-- Two rows before the shortest word
select
    lemma,
    row_number
from (
    select
        lemma,
        row_number() over () row_number
    from nouns
     ) sub2
where row_number < (
    select
        row_number
    from (
        select
            lemma,
            min(length(lemma)) over () as min,
            length(lemma),
            row_number() over () row_number
        from nouns
        ) sub
    where length(lemma) = min
    limit 1
    )
order by row_number desc
limit 2;

-- Count words' articles
select
    count(genus) count,
    case
        when genus = 'f' then 'die'
        when genus = 'm' then 'der'
        when genus = 'n' then 'das'
    end as genus
from nouns
group by genus
order by count desc;

-- Palindrome
select
    count(palindrome),
    palindrome
from (
    select
        lemma,
        case
            when reverse(lower(lemma)) = lower(lemma) then 'palindrome'
            else 'not palindrome'
    end as palindrome
    from nouns
     ) s
group by palindrome;