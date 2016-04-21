// prototype
int var2(void);
int var3(int l, int m);

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

    i = var3(1, 2) + j;
    return (i);
}

int var3(int l, int m)
{
    int i = 10;
    int j = 20;
    int k = 30;

        k = i + j + l + m;

    return (k);
}