<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="3.22.3-Białowieża" styleCategories="Fields|Forms">
  <fieldConfiguration>
    <field name="id" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="gmlid" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="gmlid_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="name" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="name_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="description" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="creation_date" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" type="bool" value="true"/>
            <Option name="calendar_popup" type="bool" value="true"/>
            <Option name="display_format" type="QString" value="dd-MM-yyyy HH:mm:ss"/>
            <Option name="field_format" type="QString" value="dd-MM-yyyy HH:mm:ss"/>
            <Option name="field_iso_format" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="termination_date" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" type="bool" value="true"/>
            <Option name="calendar_popup" type="bool" value="true"/>
            <Option name="display_format" type="QString" value="dd-MM-yyyy HH:mm:ss"/>
            <Option name="field_format" type="QString" value="dd-MM-yyyy HH:mm:ss"/>
            <Option name="field_iso_format" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="relative_to_terrain" configurationFlags="None">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" type="bool" value="false"/>
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="Description" type="QString" value=""/>
            <Option name="FilterExpression" type="QString" value=""/>
            <Option name="Key" type="QString" value="code_value"/>
            <Option name="Layer" type="QString" value="lu_relative_to_terrain_d2c60ffe_5cc3_4ece_9e46_caf7c20f21c3"/>
            <Option name="LayerName" type="QString" value="lu_relative_to_terrain"/>
            <Option name="LayerProviderName" type="QString" value="postgres"/>
            <Option name="LayerSource" type="QString" value="dbname='GEO5014' host=127.0.0.1 port=5432 user='postgres' key='code_value' checkPrimaryKeyUnicity='1' table=&quot;qgis_pkg&quot;.&quot;lu_relative_to_terrain&quot;"/>
            <Option name="NofColumns" type="int" value="1"/>
            <Option name="OrderByValue" type="bool" value="false"/>
            <Option name="UseCompleter" type="bool" value="false"/>
            <Option name="Value" type="QString" value="code_name"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="relative_to_water" configurationFlags="None">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" type="bool" value="false"/>
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="Description" type="QString" value=""/>
            <Option name="FilterExpression" type="QString" value=""/>
            <Option name="Key" type="QString" value="code_value"/>
            <Option name="Layer" type="QString" value="lu_relative_to_water_e7e84f40_a88f_4769_853d_d97d2800327e"/>
            <Option name="LayerName" type="QString" value="lu_relative_to_water"/>
            <Option name="LayerProviderName" type="QString" value="postgres"/>
            <Option name="LayerSource" type="QString" value="dbname='GEO5014' host=127.0.0.1 port=5432 user='postgres' key='code_value' checkPrimaryKeyUnicity='1' table=&quot;qgis_pkg&quot;.&quot;lu_relative_to_water&quot;"/>
            <Option name="NofColumns" type="int" value="1"/>
            <Option name="OrderByValue" type="bool" value="false"/>
            <Option name="UseCompleter" type="bool" value="false"/>
            <Option name="Value" type="QString" value="code_name"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="last_modification_date" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" type="bool" value="true"/>
            <Option name="calendar_popup" type="bool" value="true"/>
            <Option name="display_format" type="QString" value="dd-MM-yyyy HH:mm:ss"/>
            <Option name="field_format" type="QString" value="dd-MM-yyyy HH:mm:ss"/>
            <Option name="field_iso_format" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="updating_person" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="reason_for_update" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="lineage" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="class" configurationFlags="None">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" type="bool" value="false"/>
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="Description" type="QString" value=""/>
            <Option name="FilterExpression" type="QString" value=""/>
            <Option name="Key" type="QString" value="code_value"/>
            <Option name="Layer" type="QString" value="lu_building_class_5ed4b069_aa33_4582_a197_3c72372b9308"/>
            <Option name="LayerName" type="QString" value="lu_building_class"/>
            <Option name="LayerProviderName" type="QString" value="postgres"/>
            <Option name="LayerSource" type="QString" value="dbname='GEO5014' host=127.0.0.1 port=5432 user='postgres' key='code_value' checkPrimaryKeyUnicity='1' table=&quot;qgis_pkg&quot;.&quot;lu_building_class&quot;"/>
            <Option name="NofColumns" type="int" value="1"/>
            <Option name="OrderByValue" type="bool" value="false"/>
            <Option name="UseCompleter" type="bool" value="false"/>
            <Option name="Value" type="QString" value="code_name"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="class_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="function" configurationFlags="None">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" type="bool" value="true"/>
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="Description" type="QString" value=""/>
            <Option name="FilterExpression" type="QString" value="codelist_name  =  'NL BAG Gebruiksdoel'"/>
            <Option name="Key" type="QString" value="code_value"/>
            <Option name="Layer" type="QString" value="lu_building_function_usage_abf14271_6a23_48ba_a4a6_a38f398e96a3"/>
            <Option name="LayerName" type="QString" value="lu_building_function_usage"/>
            <Option name="LayerProviderName" type="QString" value="postgres"/>
            <Option name="LayerSource" type="QString" value="dbname='GEO5014' host=127.0.0.1 port=5432 user='postgres' key='code_value' checkPrimaryKeyUnicity='1' table=&quot;qgis_pkg&quot;.&quot;lu_building_function_usage&quot;"/>
            <Option name="NofColumns" type="int" value="4"/>
            <Option name="OrderByValue" type="bool" value="true"/>
            <Option name="UseCompleter" type="bool" value="false"/>
            <Option name="Value" type="QString" value="code_name"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="function_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="usage" configurationFlags="None">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" type="bool" value="true"/>
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="Description" type="QString" value="&quot;description&quot;"/>
            <Option name="FilterExpression" type="QString" value="codelist_name  =  'NL BAG Gebruiksdoel'"/>
            <Option name="Key" type="QString" value="code_value"/>
            <Option name="Layer" type="QString" value="lu_building_function_usage_abf14271_6a23_48ba_a4a6_a38f398e96a3"/>
            <Option name="LayerName" type="QString" value="lu_building_function_usage"/>
            <Option name="LayerProviderName" type="QString" value="postgres"/>
            <Option name="LayerSource" type="QString" value="dbname='GEO5014' host=127.0.0.1 port=5432 user='postgres' key='code_value' checkPrimaryKeyUnicity='1' table=&quot;qgis_pkg&quot;.&quot;lu_building_function_usage&quot;"/>
            <Option name="NofColumns" type="int" value="4"/>
            <Option name="OrderByValue" type="bool" value="true"/>
            <Option name="UseCompleter" type="bool" value="false"/>
            <Option name="Value" type="QString" value="code_name"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="usage_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="year_of_construction" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" type="bool" value="true"/>
            <Option name="calendar_popup" type="bool" value="true"/>
            <Option name="display_format" type="QString" value="yyyy"/>
            <Option name="field_format" type="QString" value="yyyy"/>
            <Option name="field_iso_format" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="year_of_demolition" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" type="bool" value="true"/>
            <Option name="calendar_popup" type="bool" value="true"/>
            <Option name="display_format" type="QString" value="yyyy"/>
            <Option name="field_format" type="QString" value="yyyy"/>
            <Option name="field_iso_format" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="roof_type" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="roof_type_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="measured_height" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="measured_height_unit" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="storeys_above_ground" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="storeys_below_ground" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="storey_heights_above_ground" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="storey_heights_ag_unit" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="storey_heights_below_ground" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="storey_heights_bg_unit" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias name="ID" index="0" field="id"/>
    <alias name="GML ID" index="1" field="gmlid"/>
    <alias name="GML codespace" index="2" field="gmlid_codespace"/>
    <alias name="Name" index="3" field="name"/>
    <alias name="Name codespace" index="4" field="name_codespace"/>
    <alias name="Description" index="5" field="description"/>
    <alias name="Creation Date" index="6" field="creation_date"/>
    <alias name="Termination Date" index="7" field="termination_date"/>
    <alias name="Relative to Terrain" index="8" field="relative_to_terrain"/>
    <alias name="Relative to Water" index="9" field="relative_to_water"/>
    <alias name="Latest Modification" index="10" field="last_modification_date"/>
    <alias name="Updating person" index="11" field="updating_person"/>
    <alias name="Updating Reason" index="12" field="reason_for_update"/>
    <alias name="Lineage" index="13" field="lineage"/>
    <alias name="Class" index="14" field="class"/>
    <alias name="Class codespace" index="15" field="class_codespace"/>
    <alias name="Function" index="16" field="function"/>
    <alias name="Function codespace" index="17" field="function_codespace"/>
    <alias name="Usage" index="18" field="usage"/>
    <alias name="Usage codespace" index="19" field="usage_codespace"/>
    <alias name="Year of Construction" index="20" field="year_of_construction"/>
    <alias name="Year of Demolition" index="21" field="year_of_demolition"/>
    <alias name="Roof Type" index="22" field="roof_type"/>
    <alias name="Roof Type codespace" index="23" field="roof_type_codespace"/>
    <alias name="Height" index="24" field="measured_height"/>
    <alias name="Height UoM" index="25" field="measured_height_unit"/>
    <alias name="Storeys above ground" index="26" field="storeys_above_ground"/>
    <alias name="Storeys below ground" index="27" field="storeys_below_ground"/>
    <alias name="Storey height above ground" index="28" field="storey_heights_above_ground"/>
    <alias name="Storey height above ground UoM" index="29" field="storey_heights_ag_unit"/>
    <alias name="Storey height below ground" index="30" field="storey_heights_below_ground"/>
    <alias name="Storey height below ground UoM" index="31" field="storey_heights_bg_unit"/>
  </aliases>
  <defaults>
    <default applyOnUpdate="0" expression="" field="id"/>
    <default applyOnUpdate="0" expression="" field="gmlid"/>
    <default applyOnUpdate="0" expression="" field="gmlid_codespace"/>
    <default applyOnUpdate="0" expression="" field="name"/>
    <default applyOnUpdate="0" expression="" field="name_codespace"/>
    <default applyOnUpdate="0" expression="" field="description"/>
    <default applyOnUpdate="0" expression="" field="creation_date"/>
    <default applyOnUpdate="0" expression="" field="termination_date"/>
    <default applyOnUpdate="0" expression="" field="relative_to_terrain"/>
    <default applyOnUpdate="0" expression="" field="relative_to_water"/>
    <default applyOnUpdate="0" expression="" field="last_modification_date"/>
    <default applyOnUpdate="0" expression="" field="updating_person"/>
    <default applyOnUpdate="0" expression="" field="reason_for_update"/>
    <default applyOnUpdate="0" expression="" field="lineage"/>
    <default applyOnUpdate="0" expression="" field="class"/>
    <default applyOnUpdate="0" expression="" field="class_codespace"/>
    <default applyOnUpdate="0" expression="" field="function"/>
    <default applyOnUpdate="0" expression="" field="function_codespace"/>
    <default applyOnUpdate="0" expression="" field="usage"/>
    <default applyOnUpdate="0" expression="" field="usage_codespace"/>
    <default applyOnUpdate="0" expression="" field="year_of_construction"/>
    <default applyOnUpdate="0" expression="" field="year_of_demolition"/>
    <default applyOnUpdate="0" expression="" field="roof_type"/>
    <default applyOnUpdate="0" expression="" field="roof_type_codespace"/>
    <default applyOnUpdate="0" expression="" field="measured_height"/>
    <default applyOnUpdate="0" expression="" field="measured_height_unit"/>
    <default applyOnUpdate="0" expression="" field="storeys_above_ground"/>
    <default applyOnUpdate="0" expression="" field="storeys_below_ground"/>
    <default applyOnUpdate="0" expression="" field="storey_heights_above_ground"/>
    <default applyOnUpdate="0" expression="" field="storey_heights_ag_unit"/>
    <default applyOnUpdate="0" expression="" field="storey_heights_below_ground"/>
    <default applyOnUpdate="0" expression="" field="storey_heights_bg_unit"/>
  </defaults>
  <constraints>
    <constraint notnull_strength="1" exp_strength="0" constraints="3" unique_strength="1" field="id"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="gmlid"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="gmlid_codespace"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="name"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="name_codespace"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="description"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="creation_date"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="termination_date"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="relative_to_terrain"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="relative_to_water"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="last_modification_date"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="updating_person"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="reason_for_update"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="lineage"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="class"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="class_codespace"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="function"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="function_codespace"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="usage"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="usage_codespace"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="year_of_construction"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="year_of_demolition"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="roof_type"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="roof_type_codespace"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="measured_height"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="measured_height_unit"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="storeys_above_ground"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="storeys_below_ground"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="storey_heights_above_ground"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="storey_heights_ag_unit"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="storey_heights_below_ground"/>
    <constraint notnull_strength="0" exp_strength="0" constraints="0" unique_strength="0" field="storey_heights_bg_unit"/>
  </constraints>
  <constraintExpressions>
    <constraint desc="" exp="" field="id"/>
    <constraint desc="" exp="" field="gmlid"/>
    <constraint desc="" exp="" field="gmlid_codespace"/>
    <constraint desc="" exp="" field="name"/>
    <constraint desc="" exp="" field="name_codespace"/>
    <constraint desc="" exp="" field="description"/>
    <constraint desc="" exp="" field="creation_date"/>
    <constraint desc="" exp="" field="termination_date"/>
    <constraint desc="" exp="" field="relative_to_terrain"/>
    <constraint desc="" exp="" field="relative_to_water"/>
    <constraint desc="" exp="" field="last_modification_date"/>
    <constraint desc="" exp="" field="updating_person"/>
    <constraint desc="" exp="" field="reason_for_update"/>
    <constraint desc="" exp="" field="lineage"/>
    <constraint desc="" exp="" field="class"/>
    <constraint desc="" exp="" field="class_codespace"/>
    <constraint desc="" exp="" field="function"/>
    <constraint desc="" exp="" field="function_codespace"/>
    <constraint desc="" exp="" field="usage"/>
    <constraint desc="" exp="" field="usage_codespace"/>
    <constraint desc="" exp="" field="year_of_construction"/>
    <constraint desc="" exp="" field="year_of_demolition"/>
    <constraint desc="" exp="" field="roof_type"/>
    <constraint desc="" exp="" field="roof_type_codespace"/>
    <constraint desc="" exp="" field="measured_height"/>
    <constraint desc="" exp="" field="measured_height_unit"/>
    <constraint desc="" exp="" field="storeys_above_ground"/>
    <constraint desc="" exp="" field="storeys_below_ground"/>
    <constraint desc="" exp="" field="storey_heights_above_ground"/>
    <constraint desc="" exp="" field="storey_heights_ag_unit"/>
    <constraint desc="" exp="" field="storey_heights_below_ground"/>
    <constraint desc="" exp="" field="storey_heights_bg_unit"/>
  </constraintExpressions>
  <expressionfields/>
  <editform tolerant="1"></editform>
  <editforminit/>
  <editforminitcodesource>0</editforminitcodesource>
  <editforminitfilepath></editforminitfilepath>
  <editforminitcode><![CDATA[# -*- coding: utf-8 -*-
"""
QGIS forms can have a Python function that is called when the form is
opened.

Use this function to add extra logic to your forms.

Enter the name of the function in the "Python Init function"
field.
An example follows:
"""
from qgis.PyQt.QtWidgets import QWidget

def my_form_open(dialog, layer, feature):
	geom = feature.geometry()
	control = dialog.findChild(QWidget, "MyLineEdit")
]]></editforminitcode>
  <featformsuppress>0</featformsuppress>
  <editorlayout>tablayout</editorlayout>
  <attributeEditorForm>
    <attributeEditorContainer name="Main Info" visibilityExpression="" columnCount="1" showLabel="1" groupBox="0" visibilityExpressionEnabled="0">
      <attributeEditorField name="id" showLabel="1" index="0"/>
      <attributeEditorField name="gmlid" showLabel="1" index="1"/>
      <attributeEditorField name="gmlid_codespace" showLabel="1" index="2"/>
      <attributeEditorField name="name" showLabel="1" index="3"/>
      <attributeEditorField name="name_codespace" showLabel="1" index="4"/>
      <attributeEditorField name="description" showLabel="1" index="5"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Database Info" visibilityExpression="" columnCount="1" showLabel="1" groupBox="0" visibilityExpressionEnabled="0">
      <attributeEditorField name="creation_date" showLabel="1" index="6"/>
      <attributeEditorField name="termination_date" showLabel="1" index="7"/>
      <attributeEditorField name="last_modification_date" showLabel="1" index="10"/>
      <attributeEditorField name="updating_person" showLabel="1" index="11"/>
      <attributeEditorField name="reason_for_update" showLabel="1" index="12"/>
      <attributeEditorField name="lineage" showLabel="1" index="13"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Other" visibilityExpression="" columnCount="1" showLabel="1" groupBox="0" visibilityExpressionEnabled="0">
      <attributeEditorContainer name="Surface Relation" visibilityExpression="" columnCount="1" showLabel="1" groupBox="1" visibilityExpressionEnabled="0">
        <attributeEditorField name="relative_to_terrain" showLabel="1" index="8"/>
        <attributeEditorField name="relative_to_water" showLabel="1" index="9"/>
      </attributeEditorContainer>
    </attributeEditorContainer>
    <attributeEditorContainer name="Generic Attributes" visibilityExpression="" columnCount="1" showLabel="1" groupBox="0" visibilityExpressionEnabled="0">
      <attributeEditorRelation name="cityobject_genericattrib_a3603ef4_3563_4f48_a3db_728ec29cafcf_cityobject_id_citydb_building_lod2_226dfee6_9d5a_4d20_b295_6d7e59bc090c_id" nmRelationId="" showLabel="0" relation="cityobject_genericattrib_a3603ef4_3563_4f48_a3db_728ec29cafcf_cityobject_id_citydb_building_lod2_226dfee6_9d5a_4d20_b295_6d7e59bc090c_id" label="Generic Attributes" relationWidgetTypeId="relation_editor" forceSuppressFormPopup="0">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="AllButtons"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Building Attributes" visibilityExpression="" columnCount="2" showLabel="1" groupBox="1" visibilityExpressionEnabled="0">
      <attributeEditorField name="measured_height" showLabel="1" index="24"/>
      <attributeEditorField name="measured_height_unit" showLabel="1" index="25"/>
      <attributeEditorField name="storey_heights_above_ground" showLabel="1" index="28"/>
      <attributeEditorField name="storey_heights_ag_unit" showLabel="1" index="29"/>
      <attributeEditorField name="storey_heights_below_ground" showLabel="1" index="30"/>
      <attributeEditorField name="storey_heights_bg_unit" showLabel="1" index="31"/>
      <attributeEditorField name="storeys_above_ground" showLabel="1" index="26"/>
      <attributeEditorField name="storeys_below_ground" showLabel="1" index="27"/>
      <attributeEditorField name="year_of_construction" showLabel="1" index="20"/>
      <attributeEditorField name="year_of_demolition" showLabel="1" index="21"/>
      <attributeEditorField name="roof_type" showLabel="1" index="22"/>
      <attributeEditorField name="roof_type_codespace" showLabel="1" index="23"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Class" visibilityExpression="" columnCount="1" showLabel="1" groupBox="0" visibilityExpressionEnabled="0">
      <attributeEditorField name="class" showLabel="1" index="14"/>
      <attributeEditorField name="class_codespace" showLabel="1" index="15"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Function" visibilityExpression="" columnCount="1" showLabel="1" groupBox="0" visibilityExpressionEnabled="0">
      <attributeEditorField name="function" showLabel="1" index="16"/>
      <attributeEditorField name="function_codespace" showLabel="1" index="17"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Usage" visibilityExpression="" columnCount="1" showLabel="1" groupBox="0" visibilityExpressionEnabled="0">
      <attributeEditorField name="usage" showLabel="1" index="18"/>
      <attributeEditorField name="usage_codespace" showLabel="1" index="19"/>
    </attributeEditorContainer>
  </attributeEditorForm>
  <editable>
    <field name="class" editable="1"/>
    <field name="class_codespace" editable="1"/>
    <field name="creation_date" editable="0"/>
    <field name="description" editable="1"/>
    <field name="function" editable="1"/>
    <field name="function_codespace" editable="1"/>
    <field name="gmlid" editable="0"/>
    <field name="gmlid_codespace" editable="1"/>
    <field name="id" editable="0"/>
    <field name="last_modification_date" editable="1"/>
    <field name="lineage" editable="1"/>
    <field name="measured_height" editable="1"/>
    <field name="measured_height_unit" editable="1"/>
    <field name="name" editable="1"/>
    <field name="name_codespace" editable="1"/>
    <field name="reason_for_update" editable="1"/>
    <field name="relative_to_terrain" editable="1"/>
    <field name="relative_to_water" editable="1"/>
    <field name="roof_type" editable="1"/>
    <field name="roof_type_codespace" editable="1"/>
    <field name="storey_heights_above_ground" editable="1"/>
    <field name="storey_heights_ag_unit" editable="1"/>
    <field name="storey_heights_below_ground" editable="1"/>
    <field name="storey_heights_bg_unit" editable="1"/>
    <field name="storeys_above_ground" editable="1"/>
    <field name="storeys_below_ground" editable="1"/>
    <field name="termination_date" editable="0"/>
    <field name="updating_person" editable="1"/>
    <field name="usage" editable="1"/>
    <field name="usage_codespace" editable="1"/>
    <field name="year_of_construction" editable="1"/>
    <field name="year_of_demolition" editable="1"/>
  </editable>
  <labelOnTop>
    <field name="class" labelOnTop="0"/>
    <field name="class_codespace" labelOnTop="0"/>
    <field name="creation_date" labelOnTop="0"/>
    <field name="description" labelOnTop="0"/>
    <field name="function" labelOnTop="0"/>
    <field name="function_codespace" labelOnTop="0"/>
    <field name="gmlid" labelOnTop="0"/>
    <field name="gmlid_codespace" labelOnTop="0"/>
    <field name="id" labelOnTop="0"/>
    <field name="last_modification_date" labelOnTop="0"/>
    <field name="lineage" labelOnTop="0"/>
    <field name="measured_height" labelOnTop="0"/>
    <field name="measured_height_unit" labelOnTop="0"/>
    <field name="name" labelOnTop="0"/>
    <field name="name_codespace" labelOnTop="0"/>
    <field name="reason_for_update" labelOnTop="0"/>
    <field name="relative_to_terrain" labelOnTop="0"/>
    <field name="relative_to_water" labelOnTop="0"/>
    <field name="roof_type" labelOnTop="0"/>
    <field name="roof_type_codespace" labelOnTop="0"/>
    <field name="storey_heights_above_ground" labelOnTop="0"/>
    <field name="storey_heights_ag_unit" labelOnTop="0"/>
    <field name="storey_heights_below_ground" labelOnTop="0"/>
    <field name="storey_heights_bg_unit" labelOnTop="0"/>
    <field name="storeys_above_ground" labelOnTop="0"/>
    <field name="storeys_below_ground" labelOnTop="0"/>
    <field name="termination_date" labelOnTop="0"/>
    <field name="updating_person" labelOnTop="0"/>
    <field name="usage" labelOnTop="0"/>
    <field name="usage_codespace" labelOnTop="0"/>
    <field name="year_of_construction" labelOnTop="0"/>
    <field name="year_of_demolition" labelOnTop="0"/>
  </labelOnTop>
  <reuseLastValue>
    <field name="class" reuseLastValue="0"/>
    <field name="class_codespace" reuseLastValue="0"/>
    <field name="creation_date" reuseLastValue="0"/>
    <field name="description" reuseLastValue="0"/>
    <field name="function" reuseLastValue="0"/>
    <field name="function_codespace" reuseLastValue="0"/>
    <field name="gmlid" reuseLastValue="0"/>
    <field name="gmlid_codespace" reuseLastValue="1"/>
    <field name="id" reuseLastValue="0"/>
    <field name="last_modification_date" reuseLastValue="0"/>
    <field name="lineage" reuseLastValue="0"/>
    <field name="measured_height" reuseLastValue="0"/>
    <field name="measured_height_unit" reuseLastValue="0"/>
    <field name="name" reuseLastValue="0"/>
    <field name="name_codespace" reuseLastValue="0"/>
    <field name="reason_for_update" reuseLastValue="0"/>
    <field name="relative_to_terrain" reuseLastValue="0"/>
    <field name="relative_to_water" reuseLastValue="0"/>
    <field name="roof_type" reuseLastValue="0"/>
    <field name="roof_type_codespace" reuseLastValue="0"/>
    <field name="storey_heights_above_ground" reuseLastValue="0"/>
    <field name="storey_heights_ag_unit" reuseLastValue="0"/>
    <field name="storey_heights_below_ground" reuseLastValue="0"/>
    <field name="storey_heights_bg_unit" reuseLastValue="0"/>
    <field name="storeys_above_ground" reuseLastValue="0"/>
    <field name="storeys_below_ground" reuseLastValue="0"/>
    <field name="termination_date" reuseLastValue="0"/>
    <field name="updating_person" reuseLastValue="0"/>
    <field name="usage" reuseLastValue="0"/>
    <field name="usage_codespace" reuseLastValue="0"/>
    <field name="year_of_construction" reuseLastValue="0"/>
    <field name="year_of_demolition" reuseLastValue="0"/>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <layerGeometryType>2</layerGeometryType>
</qgis>
