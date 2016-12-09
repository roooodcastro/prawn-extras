module Prawn
  module Extras
    module Box
      delegate :top_left, :width, :height, to: :bounds

      def last_created_box
        @last_created_box ||= nil
      end

      # Retorna um valor absoluto de width correspondente a porcentagem indicada,
      # nos limites do relatório, que é entre '0' e 'bounds.width'.
      # O parâmetro value deve ser um valor entre 0 e 100.
      # Ex: chamando percent_w(50) fora de um bounding_box: 50% da width da página
      # Ex: chamando percent_w(9) em um bounding_box: 9% da width do bounding_box
      def percent_w(value)
        # Faz o clamp no valor para garantir que ele fique entre 0% e 100%
        clamped_value = [0, value, 100].sort[1]
        bounds.width * (clamped_value / 100.0)
      end

      # Retorna um valor absoluto de height correspondente a porcentagem indicada,
      # nos limites do relatório, que é entre 'bounds.height' e '0'.
      # O parâmetro value deve ser um valor entre 0 e 100.
      # Ex: chamando percent_h(50) fora de um bounding_box: 50% da height da página
      # Ex: chamando percent_h(9) em um bounding_box: 9% da height do bounding_box
      def percent_h(value)
        # Faz o clamp no valor para garantir que ele fique entre 0% e 100%
        clamped_value = [0, value, 100].sort[1]
        bounds.height * (clamped_value / 100.0)
      end

      # Retorna um valor absoluto de height correspondente à height restante abaixo
      # de base_height. base_height deve ser um objeto do tipo Bounds
      def remaining_height(base_height)
        base_height.anchor[1] - bounds.anchor[1]
      end

      # Cria um bounding_box. Esse método é basicamente um alias de bounding_box,
      # exceto que oferece mais flexibilidade e facilidade na entrada dos
      # parâmetros, permitindo expressar width e height como porcentagens, ex:
      # box(top_left, '25%', '100%') {}
      def box(position, width, height, options = {})
        size = build_size_options(position, width, height)
        box = bounding_box(position, size) do
          padding(options[:padding] || [0, 0, 0, 0]) { yield if block_given? }
        end
        @last_created_box = box unless options[:dont_track]
        box
      end

      # Cria um novo bounding_box posicionado à direita do bounding_box pai.
      # O comportamento é o mesmo de chamar 'bounding_box', e aceita um bloco.
      # Este método retorna o bounding_box criado, para ser referenciado depois.
      # O parâmetro espaçamento é opcional e indica o tamanho do espaço entre a
      # direita do pai e a esquerda do novo bounding_box.
      def box_beside(origin_box, width, height, options = {}, &block)
        posicao = position_beside(origin_box, options[:gutter] || 0)
        box(posicao, width, height, options, &block)
      end

      # Cria um novo bounding_box posicionado à direita do último box criado.
      # Funciona como o método acima box_a_direita_de, exceto que ele pega o box
      # automaticamente. Caso não exista um último box criado (esse foi o primeiro),
      # ele irá posicionar o box no top_left.
      def box_beside_previous(width, height, options = {}, &block)
        box_beside(last_created_box, width, height, options, &block)
      end

      # Cria um novo bounding_box posicionado abaixo do bounding_box pai.
      # O comportamento é o mesmo de chamar 'bounding_box', e aceita um bloco.
      # Este método retorna o bounding_box criado, para ser referenciado depois.
      # O parâmetro espaçamento é opcional e indica o tamanho do espaço entre o
      # limite inferior do pai e o topo do novo bounding_box.
      def box_below(origin_box, width, height, options = {}, &block)
        posicao = position_below(origin_box, options[:gutter] || 0)
        box(posicao, width, height, options, &block)
      end

      # Cria um novo bounding_box posicionado abaixo do último box criado.
      # Funciona como o método acima box_abaixo_de, exceto que ele pega o box
      # automaticamente. Caso não exista um último box criado (esse foi o primeiro),
      # ele irá posicionar o box no top_left.
      def box_below_previous(width, height, opcoes = {}, &block)
        box_below(last_created_box, width, height, opcoes, &block)
      end

      # Retorna uma posição (para um novo bounding_box), imediatamente à direita
      # de um bounding_box pai, alinhado verticalmente ao topo do pai.
      # O parâmetro espaçamento é opcional e indica o tamanho do espaço entre a
      # direita do pai e a esquerda dessa nova posição.
      def position_beside(origin_box, gutter = 0)
        correct_origin = Array(origin_box).first
        return top_left if origin_box.nil?
        diff = [gutter - bounds.anchor[0], -bounds.anchor[1]]
        sum_dimensions(correct_origin.absolute_top_right, diff)
      end

      # Retorna uma posição (para um novo bounding_box), imediatamente abaixo de um
      # bounding_box pai, alinhado horizontalmente com a esquerda do pai.
      # O parâmetro espaçamento é opcional e indica o tamanho do espaço entre o
      # limite inferior do pai e o topo dessa nova posição.
      def position_below(origin_box, gutter = 0)
        correct_origin = Array(origin_box).first
        return top_left if correct_origin.nil?
        diff = [-@margin[1], -gutter.to_f - @margin[2]]
        sum_dimensions(correct_origin.absolute_bottom_left, diff)
      end

      # Cria um bounding box para agir como se fosse um padding (igual ao do CSS).
      # Tamanho pode ser um número, que será aplicado aos quatro lados, ou pode ser
      # um array com 4 valores, para o padding de cima, direita, baixo e esquerda,
      # nessa ordem.
      def padding(values)
        values = build_padding_values(values)
        posicao = padding_position(values)
        width, height = padding_size(values)
        bounding_box(posicao, width: width, height: height) { yield }
      end

      protected

      # Checa se o valor da width é uma string e contém o caractere %. Se tiver,
      # fazer o cálculo correto da width, senão, retornar a mesma width.
      # O cálculo da width é relativo ao espaço horizontal global. Para fazer ele
      # ser relativo ao espaço restante, basta adicionar um 'l' depois de '%'.
      # Espaço restante é o espaço que sobrou após a posição passada no parâmetro,
      # ou seja, se o pai ocupar metade da width da página, o valor em porcentagem
      # será relativo aos 50% livres, e não à width total da página.
      def t_width(position, width)
        return width unless width.to_s.include? '%'
        valor = percent_w(width.to_f) # Valor percentual global
        return valor unless width.to_s.include? 'l' # 'l' de 'local'
        valor * (1.0 - (position.first / bounds.width)) # Valor percentual relativo
      end

      # Checa se o valor da height é uma string e contém o caractere %. Se tiver,
      # fazer o cálculo correto da width, senão, retornar a mesma height.
      # O cálculo da height é relativo ao espaço vertical global. Para fazer ele
      # ser relativo ao espaço restante, basta adicionar um 'l' depois de '%'.
      # Espaço restante é o espaço que sobrou após a posição passada no parâmetro,
      # ou seja, se o pai ocupar metade da height da página, o valor em porcentagem
      # será relativo aos 50% livres, e não à height total da página.
      def t_height(position, height)
        return height unless height.to_s.include? '%'
        valor = percent_h(height.to_f) # Valor percentual global
        return valor unless height.to_s.include? 'l' # 'l' de 'local'
        valor * (position.last / bounds.height) # Valor percentual relativo
      end

      def build_padding_values(values)
        values = [values.to_i] * 4 unless values.is_a? Array
        values.map(&:to_i)[0..3]
      end

      def padding_position(values)
        [values[3], bounds.top - values[0]]
      end

      def padding_size(values)
        horizontal_padding = values[1] + values[3]
        vertical_padding = values[0] + values[2]
        [bounds.width - horizontal_padding, bounds.height - vertical_padding]
      end

      def sum_dimensions(dim_a, dim_b)
        [dim_a, dim_b].transpose.map { |x| x.reduce(:+) }
      end

      def build_size_options(position, width, height)
        { width: t_width(position, width), height: t_height(position, height) }
      end
    end
  end
end

Prawn::Document.include Prawn::Extras::Box
