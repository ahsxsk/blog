C++向Lua传递数组

没什么解释，直接贴代码

cnid.lua 这个不是重点

    
    
    --verify cnid
    function verify_cnid(id)
    	--校验位
    	local verifymap = {1, 0, 88, 9, 8, 7, 6, 5, 4, 3, 2}
    	--加权因子
    	local factor = {7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2}
    	--加权和
    	local sum = 0
    	local index = 1
    	while index ~= 18 do --身份证长18位
    		sum = sum + (id[index]) * factor[index]
    		index = index + 1
    	end
    	--求模11
    	local r = sum % 11
    	if verifymap[r + 1] ==  id[18] then
    		return true
    	else
    		return false
    	end
    end

luacnid.cpp

    
    
    #include <cstdlib>
    #include <iostream>
    extern "C" {
    	#include <lua.h>
    	#include <lualib.h>
    	#include <lauxlib.h>
    }
    
    typedef unsigned short wchar;
    //point to Lua Interpreter
    //lua_State *L;
    
    bool lua_verify(lua_State *L, wchar * id, int len)
    {
    	//get lua function name
    	lua_getglobal(L, "verify_cnid");
    	//get lua function parameter
    	//create a new table
    	lua_newtable(L); 
    	lua_pushnumber(L, -1); //push -1 into stack
    	lua_rawseti(L, -2, 0); //set array[0] by -1
    	for(int i = 0; i < len; i++)
    	{
    		lua_pushinteger(L, id[i]); //push 
    		lua_rawseti(L, -2, i+1); //
    	}
    	//call function, 1 parameter, 1 return value
    	lua_call(L, 1, 1);
    	//get result
    	bool result = (bool)lua_toboolean(L, -1);
    	lua_pop(L, 1);
    	
    	return result;
    }
    
    int main()
    {
    	lua_State *L;
    	//init Lua
    	L = lua_open();
    	//load Lua libs
    	luaL_openlibs(L);	
    	//load lua file
    	luaL_dofile(L, "cnid.lua");
    	//call Lua function
    	wchar id[] = {4,4,2,3,2,5,1,8,8,0,0,4,1,8,4,0,4,3};
    	bool result = lua_verify(L, id, 18);
    	std::cout << result << std::endl;
    	//clear Lua
    	lua_close(L);
    
    	return 0;
    }

  

  

