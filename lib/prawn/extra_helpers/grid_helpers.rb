module Prawn
  module ExtraHelpers
    # Módulo para gerar um grid de células de tamanhos definidos. Parecido com uma
    # tabela HTML, mas com maior facilidade e flexibilidade para fazer colspans.

    # Não deve ser usado para dados tabulares, para isso deve-se usar o Prawn Table.
    #
    # O método gerar grid gera um grid com o número de linhas e colunas passados nos
    # parâmetros. O tamanho será 100% do bounding_box que ele se encontra, exceto
    # quando houver um padding, nesse caso o tamanho será o do box menos o padding.
    #
    # Para gerar um grid de, por exemplo, 4 colunas e 3 linhas, chame:
    #
    #   gerar_grid(4, 3, opcoes_que_sao_opcionais_e_podem_ser_omitidas) do
    #     campo_grid(linha, coluna, titulo, texto)
    #   end
    #
    # Para gerar cada célula individualmente, use o método campo_grid ou os métodos
    # derivados desse. O parâmetro linha é a linha do grid aonde o campo vai ficar,
    # e o parâmetro colunas pode ser tanto um número quando um array com 2
    # elementos. Se for um número, a coluna vai ser a do número, mas se for um
    # array, como por exemplo [0, 2], significa que a célula vai ocupar as colunas
    # 0, 1 e 2 da linha selecionada. Isso é equivalente ao colspan do HTML.
    #
    # Ilustração de um grid de 4 colunas, 3 linhas com um padding de, por exemplo,
    # 10pt (para exemplificar, digamos que 10pt = 1 linha de comentário):
    #
    # Bounding Box:
    # |------------------------------------------------------------------------|
    # |   Grid:                                                                |
    # |   |---------------|---------------|---------------|---------------|    |
    # |   | Cell 1        | Cell 2        | ...           | Index: [0, 3] |    |
    # |   |---------------|---------------|---------------|---------------|    |
    # |   | Index: [1, 0] | Index: [1, 1] | Index: [1, 2] | Index: [1, 3] |    |
    # |   |---------------|---------------|---------------|---------------|    |
    # |   | Index: [2, 0] | Index: [2, 1] | Index: [2, 2] | Index: [2, 3] |    |
    # |   |---------------|---------------|---------------|---------------|    |
    # |                                                                        |
    # |------------------------------------------------------------------------|
    #
    # Exemplos: gerar células no grid acima:
    #
    #   campo_grid(0, 1)      ==> Corresponde à Célula 2
    #   campo_grid(1, [0, 3]) ==> Corresponde a toda a segunda linha
    #
    # Na hora de gerar o grid, algumas opções podem ser passadas:
    #
    # Padding: Adiciona um padding no grid inteiro em relação ao bonding_box que
    #          contém o grid.
    # Leading: Usa o leading escolhido no grid. O leading é resetado para o valor
    #          anterior quando o grid terminar de ser definido.
    # Gutter:  O espaço entre as células, em pts. Funciona como o cellspacing da tag
    #          <table> do HTML.
    module GridHelpers
      include TextHelpers
      include BoxHelpers

      def gerar_grid(num_cols, num_linhas, opcoes = {})
        opcoes = opcoes_grid(opcoes)
        padding(opcoes[:padding]) do
          define_grid(columns: num_cols, rows: num_linhas, gutter: opcoes[:gutter])
          salvando_leading(opcoes[:leading]) { yield }
        end
      end

      def campo_grid(linha, colunas)
        colunas = [colunas] * 2 unless colunas.is_a? Array
        grid([linha, colunas[0]], [linha, colunas[1]]).bounding_box { yield }
      end

      def texto_grid(linha, colunas, label, texto)
        campo_grid(linha, colunas) { texto_com_titulo(label, texto.to_s) }
      end

      protected

      def opcoes_grid(opcoes)
        # Gutter é o espaçamento entre células, tipo o cellspacing do HTML
        # Padding é o padding do grid como um todo
        { leading: opcoes[:leading] || default_leading,
          padding: opcoes[:padding] || 0, gutter: opcoes[:gutter] || 0 }
      end

      def salvando_leading(leading)
        old_leading = default_leading
        default_leading(leading)
        yield
        default_leading(old_leading)
      end
    end
  end
end

Prawn::Document.include Prawn::ExtraHelpers::GridHelpers
