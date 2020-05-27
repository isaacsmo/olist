select DT_SGMT, 
       count(DISTINCT seller_id)
from tb_seller_sgmt
group by DT_SGMT