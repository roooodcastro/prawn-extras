module Prawn
  module ExtraHelpers
    # ==============================================================================
    #
    # Esse módulo contém helpers para facilitar a inserção de conteúdo dinâmico em
    # repeaters que são dinâmicos.
    #
    # Esses métodos controlam um hash de valores mapeados pelo número da página.
    # Utilizar esse mapa é necessário, pois ao contrário do repeater normal, que o
    # Prawn renderiza na hora e mantém o mesmo até o final, com o repeater dinâmico
    # ele deixa para renderizá-lo no final de tudo, por isso se o valor de alguma
    # variável mudar no meio da geração do relatório, o repeater dinâmico não terá
    # acesso ao valor anterior.

    # Uma das únicas variáveis que podemos contar para ter um controle do que botar
    # em cada página, na hora de renderizar o repeater dinâmico é a 'page_number'.
    # É esse page_number que usamos como chave do hash. Mais precisamente, usamos um
    # range de números de páginas, de forma com que não precisamos replicar o valor
    # para todas as páginas, podemos ter apenas algo no sentido de que um valor tal
    # se aplica às páginas entre 'x' e 'y'.
    #
    # Ex: Entre a primeira e terceira página, o relatório itera sobre o curso "A".
    # Logo, O cabeçalho das páginas 0, 1 e 2 deverá conter o curso "A". Na quarta
    # página, o curso sendo iterado troca pro curso "B", então deve ser criada
    # outra entrada no hash (mapa) dos cursos.
    #
    # A estrutura final do mapa é algo parecido com:
    # { 0..2=>"A", 3..6=>"B", 7=>"C" }
    # As duas primeiras entradas são Ranges, para facilitar o mapeamento de uma
    # página do meio do range, porém a última entrada é um Fixnum, pois esse é o
    # último curso, e não sabemos qual é a última página (não precisamos saber).
    # Nesse caso, toda a requisição de nome de curso depois da página 7 retornará
    # o valor dessa página, ou seja, "C".
    #
    #
    # Exemplo de utilização: Deseja-se agrupar alunos por curso, e cada vez que o
    # curso muda há uma quebra de página, de forma que o nome do curso deve ser
    # impresso no cabeçalho do relatório, sempre o curso do grupo atual de alunos.
    #
    # Nesse caso, no cabeçalho terá algo do tipo:
    # 'text(valor_na_pagina(:nome_curso, page_number))'
    #
    # E, dentro do '.each' que itera sobre os cursos, algo do tipo:
    # cursos.each do |curso|
    #   start_new_line
    #   set_valor_na_pagina(:nome_curso, curso, page_number)
    #   /* Tabela de alunos */
    # end
    #
    # ==========================================================================
    module DynamicRepeaterHelpers
      # Insere um valor no mapa de valores por página. Esse método deve ser chamado
      # toda vez que trocar o valor da variável, logo após a troca, e também no
      # início do relatório, para setar o valor inicial.
      #
      # Primeiro, acha a pag_inicial pela chave que é um número, e não um range.
      # Retorna sem criar o range caso a página sendo inserida for 0. Esse caso
      # significa que esse é o primeiro valor sendo inserido, então não há uma
      # chave numérica anterior para transformar em um range ou deletar.
      # Por fim, (re)insere o valor no range de páginas e deleta a chave antiga
      def set_valor_na_pagina(chave, valor, num_pagina)
        num_pagina.downto(0).each do |index|
          valor_maior_index = mapa(chave)[maior_index(chave)]
          mapa(chave)[index] = valor_maior_index unless mapa(chave).key?(index)
        end
        mapa(chave)[num_pagina] = valor # Insere o novo valor como um número
      end

      # Retorna o valor de uma chave, da página atual do relatório.
      # Se o número for maior que a maior página no mapa, retorna essa maior.
      def valor_por_pagina(chave, pagina, default = '')
        if pagina > maior_index(chave)
          return valor_por_pagina(chave, maior_index(chave), default)
        end
        mapa(chave)[pagina] || default
      end

      private

      def maior_index(chave)
        mapa(chave).keys.map { |k| k.try(:max) || k }.max.to_i
      end

      def mapa(chave)
        @mapa_repeater ||= {}
        @mapa_repeater[chave] ||= {}
        @mapa_repeater[chave]
      end
    end
  end
end

Prawn::Document.include Prawn::ExtraHelpers::DynamicRepeaterHelpers
