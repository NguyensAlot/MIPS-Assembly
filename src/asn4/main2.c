// prototype
int var2(void);
int var3(void);

void main(void)
{
    int i = 10;
    int j = 20;

    i = var2();
    j = i + 1;

}

int var2(void)
{
    int i = 10;
    int j = 20;

    i = var3() + j;   // Nested function call! No arguments passed.
    return (i);
}

int var3(void)
{
    int i = 10;
    int j = 20;
    int k = 30;

        j = i + k;

    return (j);
}