module Prawn
  module ExtraHelpers
    # ==============================================================================
    #
    # Esse módulo contém helpers para facilitar a inserção de conteúdo dinâmico
    # em repeaters que são dinâmicos.
    #
    # Esses métodos controlam um hash de valores mapeados pelo número da página.
    # Utilizar esse repeater_values é necessário, pois ao contrário do repeater
    # normal, que o Prawn renderiza na hora e mantém o mesmo até o final, com o
    # repeater dinâmico ele deixa para renderizá-lo no final de tudo, por isso
    # se o valor de alguma variável mudar no meio da geração do relatório, o
    # repeater dinâmico não terá acesso ao valor anterior.

    # Exemplo de utilização: Deseja-se agrupar alunos por curso, e cada vez que
    # o curso muda há uma quebra de página, de forma que o nome do curso deve
    # ser impresso no cabeçalho do relatório, sempre o curso do grupo atual de
    # alunos.
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
      # Saves a named value for a specific page of the generated PDF. This will
      # save the value for the specified page down to the first page of the
      # document (page 1), or until there's already another value saved for a
      # previous page.
      #
      # Example:
      #
      # store_value_in_page(:name, 'John', 3)
      #
      # This will save the value "John" at the :name key for the pages 1, 2
      # and 3. Any subsequent calls to this method (for the same key) will not
      # override these values.
      #
      def store_value_in_page(key, value, page = page_number)
        page.downto(1).each do |page_index|
          next if repeater_values(key).keys.include?[page_index]
          repeater_values(key)[page_index] = value
        end
      end

      # Returns the value for a key at a specific page. If the page is greater
      # than the highest saved page, the highest value is returned.
      #
      # Examples:
      #
      # save_repeater_value(:name, 'John', 3)
      # save_repeater_value(:name, 'Jane', 5)
      #
      # value_in_page(:name, 1) => "John"
      # value_in_page(:name, 2) => "John"
      # value_in_page(:name, 3) => "John"
      # value_in_page(:name, 4) => "Jane"
      # value_in_page(:name, 5) => "Jane"
      # value_in_page(:name, 6) => "Jane"
      # value_in_page(:name, -1) => ""
      #
      def value_in_page(key, page, default_value = '')
        repeater_values(key)[[page, max_index(key).min]] || default_value
      end

      private

      def max_index(key)
        repeater_values(key).keys.max
      end

      def repeater_values(key)
        @repeater_values ||= {}
        @repeater_values[key] ||= {}
        @repeater_values[key]
      end
    end
  end
end

Prawn::Document.include Prawn::ExtraHelpers::DynamicRepeater
