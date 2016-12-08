module Prawn
  module ExtraHelpers
    module BoxHelpers
      delegate :top_left, :width, :height, to: :bounds

      def last_created_box
        @last_created_box ||= nil
      end

      # Retorna um valor absoluto de largura correspondente a porcentagem indicada,
      # nos limites do relatório, que é entre '0' e 'bounds.width'.
      # O parâmetro value deve ser um valor entre 0 e 100.
      # Ex: chamando percent_w(50) fora de um bounding_box: 50% da largura da página
      # Ex: chamando percent_w(9) em um bounding_box: 9% da largura do bounding_box
      def percent_w(value)
        # Faz o clamp no valor para garantir que ele fique entre 0% e 100%
        clamped_value = [0, value, 100].sort[1]
        bounds.width * (clamped_value / 100.0)
      end

      # Retorna um valor absoluto de altura correspondente a porcentagem indicada,
      # nos limites do relatório, que é entre 'bounds.height' e '0'.
      # O parâmetro value deve ser um valor entre 0 e 100.
      # Ex: chamando percent_h(50) fora de um bounding_box: 50% da altura da página
      # Ex: chamando percent_h(9) em um bounding_box: 9% da altura do bounding_box
      def percent_h(value)
        # Faz o clamp no valor para garantir que ele fique entre 0% e 100%
        clamped_value = [0, value, 100].sort[1]
        bounds.height * (clamped_value / 100.0)
      end

      # Retorna um valor absoluto de altura correspondente à altura restante abaixo
      # de base_height. base_height deve ser um objeto do tipo Bounds
      def remaining_height(base_height)
        base_height.anchor[1] - bounds.anchor[1]
      end

      # Cria um bounding_box. Esse método é basicamente um alias de bounding_box,
      # exceto que oferece mais flexibilidade e facilidade na entrada dos
      # parâmetros, permitindo expressar largura e altura como porcentagens, ex:
      # box(top_left, '25%', '100%') {}
      def box(pos, largura, altura, opcoes = {})
        pad = opcoes[:padding] || [0, 0, 0, 0]
        size = { width: t_largura(pos, largura), height: t_altura(pos, altura) }
        box = bounding_box(pos, size) { padding(pad) { yield if block_given? } }
        @last_created_box = box unless opcoes[:nao_salvar_box]
        box
      end

      # Cria um novo bounding_box posicionado à direita do bounding_box pai.
      # O comportamento é o mesmo de chamar 'bounding_box', e aceita um bloco.
      # Este método retorna o bounding_box criado, para ser referenciado depois.
      # O parâmetro espaçamento é opcional e indica o tamanho do espaço entre a
      # direita do pai e a esquerda do novo bounding_box.
      def box_a_direita_de(box_pai, largura, altura, opcoes = {}, &block)
        posicao = posicao_a_direita_de(box_pai, opcoes[:espacamento] || 0)
        box(posicao, largura, altura, opcoes, &block)
      end

      # Cria um novo bounding_box posicionado à direita do último box criado.
      # Funciona como o método acima box_a_direita_de, exceto que ele pega o box
      # automaticamente. Caso não exista um último box criado (esse foi o primeiro),
      # ele irá posicionar o box no top_left.
      def box_a_direita_do_ultimo(largura, altura, opcoes = {}, &block)
        box_a_direita_de(last_created_box, largura, altura, opcoes, &block)
      end

      # Cria um novo bounding_box posicionado abaixo do bounding_box pai.
      # O comportamento é o mesmo de chamar 'bounding_box', e aceita um bloco.
      # Este método retorna o bounding_box criado, para ser referenciado depois.
      # O parâmetro espaçamento é opcional e indica o tamanho do espaço entre o
      # limite inferior do pai e o topo do novo bounding_box.
      def box_abaixo_de(box_pai, largura, altura, opcoes = {}, &block)
        posicao = posicao_abaixo_de(box_pai, opcoes[:espacamento] || 0)
        box(posicao, largura, altura, opcoes, &block)
      end

      # Cria um novo bounding_box posicionado abaixo do último box criado.
      # Funciona como o método acima box_abaixo_de, exceto que ele pega o box
      # automaticamente. Caso não exista um último box criado (esse foi o primeiro),
      # ele irá posicionar o box no top_left.
      def box_abaixo_do_ultimo(largura, altura, opcoes = {}, &block)
        box_abaixo_de(last_created_box, largura, altura, opcoes, &block)
      end

      # Retorna uma posição (para um novo bounding_box), imediatamente à direita
      # de um bounding_box pai, alinhado verticalmente ao topo do pai.
      # O parâmetro espaçamento é opcional e indica o tamanho do espaço entre a
      # direita do pai e a esquerda dessa nova posição.
      def posicao_a_direita_de(box_pai, espacamento = 0)
        pai_certo = Array(box_pai).first
        return top_left if box_pai.nil?
        diferenca = [espacamento - bounds.anchor[0], -bounds.anchor[1]]
        sum_dimensions(pai_certo.absolute_top_right, diferenca)
      end

      # Retorna uma posição (para um novo bounding_box), imediatamente abaixo de um
      # bounding_box pai, alinhado horizontalmente com a esquerda do pai.
      # O parâmetro espaçamento é opcional e indica o tamanho do espaço entre o
      # limite inferior do pai e o topo dessa nova posição.
      def posicao_abaixo_de(box_pai, espacamento = 0)
        pai_certo = Array(box_pai).first
        return top_left if pai_certo.nil?
        diferenca = [-@margin[1], -espacamento.to_f - @margin[2]]
        sum_dimensions(pai_certo.absolute_bottom_left, diferenca)
      end

      # Cria um bounding box para agir como se fosse um padding (igual ao do CSS).
      # Tamanho pode ser um número, que será aplicado aos quatro lados, ou pode ser
      # um array com 4 valores, para o padding de cima, direita, baixo e esquerda,
      # nessa ordem.
      def padding(medidas)
        medidas = acerta_medidas_padding(medidas)
        posicao = posicao_padding(medidas)
        largura, altura = tamanho_padding(medidas)
        bounding_box(posicao, width: largura, height: altura) { yield }
      end

      protected

      # Checa se o valor da largura é uma string e contém o caractere %. Se tiver,
      # fazer o cálculo correto da largura, senão, retornar a mesma largura.
      # O cálculo da largura é relativo ao espaço horizontal global. Para fazer ele
      # ser relativo ao espaço restante, basta adicionar um 'l' depois de '%'.
      # Espaço restante é o espaço que sobrou após a posição passada no parâmetro,
      # ou seja, se o pai ocupar metade da largura da página, o valor em porcentagem
      # será relativo aos 50% livres, e não à largura total da página.
      def t_largura(posicao, largura)
        return largura unless largura.to_s.include? '%'
        valor = percent_w(largura.to_f) # Valor percentual global
        return valor unless largura.to_s.include? 'l' # 'l' de 'local'
        valor * (1.0 - (posicao.first / bounds.width)) # Valor percentual relativo
      end

      # Checa se o valor da altura é uma string e contém o caractere %. Se tiver,
      # fazer o cálculo correto da largura, senão, retornar a mesma altura.
      # O cálculo da altura é relativo ao espaço vertical global. Para fazer ele
      # ser relativo ao espaço restante, basta adicionar um 'l' depois de '%'.
      # Espaço restante é o espaço que sobrou após a posição passada no parâmetro,
      # ou seja, se o pai ocupar metade da altura da página, o valor em porcentagem
      # será relativo aos 50% livres, e não à altura total da página.
      def t_altura(posicao, altura)
        return altura unless altura.to_s.include? '%'
        valor = percent_h(altura.to_f) # Valor percentual global
        return valor unless altura.to_s.include? 'l' # 'l' de 'local'
        valor * (posicao.last / bounds.height) # Valor percentual relativo
      end

      def acerta_medidas_padding(medidas)
        medidas = [medidas.to_i] * 4 unless medidas.is_a? Array
        medidas.map(&:to_i)[0..3]
      end

      def posicao_padding(medidas)
        [medidas[3], bounds.top - medidas[0]]
      end

      def tamanho_padding(medidas)
        padding_horizontal = medidas[1] + medidas[3]
        padding_vertical = medidas[0] + medidas[2]
        [bounds.width - padding_horizontal, bounds.height - padding_vertical]
      end

      # Faz uma soma dos elementos de um array. Exemplo:
      # a = [2, 2, 2]; b = [0, 1, 2]
      # sum_dimensions(a, b) => [2, 3, 4]
      def sum_dimensions(dim_a, dim_b)
        [dim_a, dim_b].transpose.map {|x| x.reduce(:+)}
      end
    end
  end
end

Prawn::Document.include Prawn::ExtraHelpers::BoxHelpers
