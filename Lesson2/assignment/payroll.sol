pragma solidity ^0.4.14;

contract Payroll {
    uint constant payDuration = 10 seconds;

    uint total;

    address owner;
    
    struct Employee{
        address id;
        uint salary;
        uint lastPayday;
    }

    Employee[] employees;

    function Payroll() payable public{
        owner = msg.sender;
    }
    // 打印出雇员信息
    event employeesLog(address id, uint salary, uint lastPayday);
    function printEmployeesInfo() private{
        for(uint i = 0; i < employees.length; i ++){
              employeesLog(employees[i].id, employees[i].salary,employees[i].lastPayday);
        }
    }

   // 给雇员发工资
    function _partialPaid(Employee employee) private{
        uint payment = employee.salary * (now - employee.lastPayday) / payDuration;
        employee.id.transfer(payment);
    }

    // 从数组里查询雇员
    function _findEmployee(address e) private returns (Employee, uint){
        printEmployeesInfo();
        for (uint i = 0; i < employees.length; i++){
            if (employees[i].id == e){
                return (employees[i], i);
            }
        }
    }

   // 增加雇员
    function addEmployee(address e, uint s) public{
        require(msg.sender == owner);
        var (employee, index) = _findEmployee(e);
        //require(index != 0x0);
        //require(employee.id != 0x0);
        employees.push(Employee(e, s * 1 ether, now));
        total = total + s;
        printEmployeesInfo();
    }

    // 删除雇员
    function removeEmployee(address e) public{
        require(msg.sender == owner);
        var (employee, index) = _findEmployee(e);
        assert(employee.id != 0x0);
        _partialPaid(employee);
        total = total - employee.salary;
        delete employees[index];
        employees[index] = employees[employees.length - 1];
        employees.length -= 1;
    }

     // 更新雇员
    function updateEmployee(address e, uint s) public{
        require(msg.sender == owner);
        var (employee, index) = _findEmployee(e);
        assert(employee.id != 0x0);
        _partialPaid(employee);
        total = total - employee.salary;
        employees[index].salary = s * 1 ether;
        employees[index].lastPayday = now;
        total = total + s;
    }

    // 打印公司剩余资金及雇员总数
    event log(uint balance, uint total);
    function addFund() payable public returns (uint) {
        log(this.balance, total);
        return this.balance;
    }

    // 计算还可以发多少次工资
    function calculateRunway() public returns (uint){
         log(this.balance, total);
        return this.balance / total;
    }

   // 判断是否还可以发一次工资
    function hasEnoughFund() public returns (bool) {
        return calculateRunway() > 0;
    }

    // 给员工发工资
    function getPaid() public{
        var (employee, index) = _findEmployee(msg.sender);
        assert(employee.id != 0x0);

        uint nextPayday = employee.lastPayday + payDuration;
        assert(nextPayday < now);

        employees[index].lastPayday = nextPayday;
        employees[index].id.transfer(employee.salary);
    }
}
