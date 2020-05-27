select T1.*,
        case when pct_receita <= 0.5 and pct_freq <= 0.5 then 'BAIXO VALOR E FREQ'
                when pct_receita > 0.5 and pct_freq <= 0.5 then 'ALTO VALOR'
                when pct_receita <= 0.5 and pct_freq > 0.5 then 'ALTA FREQUENCIA'
                when pct_receita < 0.9 or pct_freq < 0.9 then 'PRODUTIVO'
                else 'SUPER PRODUTIVO'
        end as SEGMENTO_VALOR_FREQ,

        case when qtde_dias_base <=60 then 'INICIO'
                when qtde_dias_base <=300 then 'RETENCAO'
                else 'ATIVO'
        end as SEGMENTO_VIDA,
        '{date_end}' as DT_SGMT

from(

        select T1.*,
                percent_rank() over ( order by receita_total asc) as pct_receita,
                percent_rank() over ( order by qtde_pedidos asc) as pct_freq


        from (

                select T2.seller_id,
                        sum( T2.price ) as receita_total,
                        count( T1.order_id ) as qtde_pedidos,
                        count( T2.product_id) as qtde_produtos,
                        count( DISTINCT T2.product_id) as qtde_produtos,
                        min( CAST(julianday( '{date_end}' ) - julianday(T1.order_approved_at) as INT )) as qtde_dias_ult_venda,
                        max( CAST(julianday( '{date_end}' ) - julianday(dt_inicio) as INT ) ) as qtde_dias_base
                from tb_orders as T1

                left join tb_order_items as T2
                on T1.order_id = T2.order_id

                left JOIN(
                        select T2.seller_id, 
                                min(date(t1.order_approved_at)) as dt_inicio
                        from tb_orders as T1
                        left join tb_order_items as T2
                        on T1.order_id = T2.order_id
                        group by T2.seller_id
                ) as T3
                on T2.seller_id = T3.seller_id

                where T1.order_approved_at between '{date_init}' and '{date_end}'

                group by T2.seller_id

                order by receita_total desc

        ) as T1
) as T1

where seller_id is not NULL