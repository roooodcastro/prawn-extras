module Prawn
  module Extras
    # Módulo para gerar um grid de células de tamanhos definidos. Parecido com uma
    # tabela HTML, mas com maior facilidade e flexibilidade para fazer colspans.
    #
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
    module Grid
      include Text
      include Box

      def define_grid_block(columns, rows, options = {})
        options = build_grid_options(columns, rows, options)
        padding(options.delete(:padding)) do
          leading = options.delete(:leading)
          define_grid(options)
          save_leading(leading) { yield }
        end
      end

      def grid_cell(row, columns)
        columns = [columns] * 2 unless columns.is_a? Array
        grid([row, columns[0]], [row, columns[1]]).bounding_box { yield }
      end

      def text_grid_cell(row, columns, label_or_text, text = nil)
        grid_cell(row, columns) do
          titled_text(label_or_text, text) if text
          text_box(label_or_text) unless text
        end
      end

      protected

      def build_grid_options(columns, rows, options)
        options.merge(columns: columns, rows: rows)
      end
    end
  end
end

Prawn::Document.include Prawn::Extras::Grid
