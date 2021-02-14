a, b, c = 1, 2, 3
print(a, b, c)
# sep = '' 으로 원하는대로 출력 가능
print(a, b, c, sep=', ')
print(a, b, c, sep='\n')

print('------')
# python의 print는 기본적으로 뛰어쓰기('\n') 내장 end = ''로 조절 가능
print(a, end=' ')
print(b, end=' ')
