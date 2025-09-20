import psycopg2

def conectar():
    try:
        conn = psycopg2.connect(
            dbname="Ecommerce",
            user="postgres",
            password="Milomanheim13!",
            host="localhost",
            port="5432"
        )
        return conn
    except Exception as e:
        print("❌ Erro na conexão com o banco:", e)
        return None

def executar_funcao(conn, funcao):
    try:
        cur = conn.cursor()
        cur.execute(f"SELECT * FROM {funcao}();")
        resultado = cur.fetchall()
        cur.close()
        return resultado
    except Exception as e:
        print(f"❌ Erro ao executar {funcao}():", e)
        return None

def mostrar_resultado(funcao, resultado):
    print("\n✨ Resultado ✨")
    if funcao == "produto_mais_vendido":
        print(f"🔝 Produto mais vendido: {resultado[0][0]} com {resultado[0][1]} unidades")
    elif funcao == "situacao_estoque":
        print("📦 Estoque atual:")
        for linha in resultado:
            print(f"🛍 Produto: {linha[0]} | Quantidade: {linha[1]} | Local: {linha[2]}")
    elif funcao == "melhor_cliente":
        print(f"👑 Melhor cliente: {resultado[0][0]} com R$ {resultado[0][1]:.2f} em compras")
    print("")

def interpretar_pergunta(pergunta):
    pergunta = pergunta.lower()
    if "produto mais vendido" in pergunta:
        return "produto_mais_vendido"
    elif "estoque" in pergunta or "situação" in pergunta:
        return "situacao_estoque"
    elif "melhor cliente" in pergunta:
        return "melhor_cliente"
    else:
        return None

def menu():
    print("🌟 Pergunte algo sobre o sistema:")
    print("📌 Ex: 'Qual é o produto mais vendido?'")
    print("📌 Ex: 'Qual é a situação do estoque?'")
    print("📌 Ex: 'Quem é o melhor cliente?'")
    print("💌 Digite 'sair' para encerrar.")
    print("")

    conn = conectar()
    if not conn:
        return

    while True:
        pergunta = input("❓ Sua pergunta: ")
        if pergunta.lower() == "sair":
            print("👋 Encerrando... Até mais, florzinha!")
            break

        funcao = interpretar_pergunta(pergunta)
        if funcao:
            resultado = executar_funcao(conn, funcao)
            if resultado:
                mostrar_resultado(funcao, resultado)
        else:
            print("🤔 Não entendi essa pergunta... Tente perguntar de outro jeitinho!\n")

    conn.close()

# 🎀 Início do programa
if __name__ == "__main__":
    menu()
