<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="3.22.16-Białowieża" styleCategories="Fields|Forms">
  <fieldConfiguration>
    <field name="id" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" name="IsMultiline" value="false"/>
            <Option type="bool" name="UseHtml" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="gmlid" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" name="IsMultiline" value="false"/>
            <Option type="bool" name="UseHtml" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="gmlid_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" name="IsMultiline" value="false"/>
            <Option type="bool" name="UseHtml" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="name" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" name="IsMultiline" value="false"/>
            <Option type="bool" name="UseHtml" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="name_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="description" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="creation_date" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option type="bool" name="allow_null" value="true"/>
            <Option type="bool" name="calendar_popup" value="true"/>
            <Option type="QString" name="display_format" value="dd-MM-yyyy HH:mm:ss"/>
            <Option type="QString" name="field_format" value="dd-MM-yyyy HH:mm:ss"/>
            <Option type="bool" name="field_iso_format" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="termination_date" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option type="bool" name="allow_null" value="true"/>
            <Option type="bool" name="calendar_popup" value="true"/>
            <Option type="QString" name="display_format" value="dd-MM-yyyy HH:mm:ss"/>
            <Option type="QString" name="field_format" value="dd-MM-yyyy HH:mm:ss"/>
            <Option type="bool" name="field_iso_format" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="relative_to_terrain" configurationFlags="None">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" name="AllowMulti" value="false"/>
            <Option type="bool" name="AllowNull" value="true"/>
            <Option type="QString" name="FilterExpression" value="data_model = 'CityGML 2.0' AND name = 'RelativeToTerrainType'"/>
            <Option type="QString" name="Key" value="value"/>
            <Option type="QString" name="Layer" value="alderaan_v_enumeration_value_c48b3a42_2d3e_4d41_a139_8dc7da82a940"/>
            <Option type="int" name="NofColumns" value="1"/>
            <Option type="bool" name="OrderByValue" value="false"/>
            <Option type="bool" name="UseCompleter" value="false"/>
            <Option type="QString" name="Value" value="description"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="relative_to_water" configurationFlags="None">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option type="bool" name="AllowMulti" value="false"/>
            <Option type="bool" name="AllowNull" value="true"/>
            <Option type="QString" name="FilterExpression" value="data_model = 'CityGML 2.0' AND name = 'RelativeToWaterType'"/>
            <Option type="QString" name="Key" value="value"/>
            <Option type="QString" name="Layer" value="alderaan_v_enumeration_value_c48b3a42_2d3e_4d41_a139_8dc7da82a940"/>
            <Option type="int" name="NofColumns" value="1"/>
            <Option type="bool" name="OrderByValue" value="false"/>
            <Option type="bool" name="UseCompleter" value="false"/>
            <Option type="QString" name="Value" value="description"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="last_modification_date" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option type="bool" name="allow_null" value="true"/>
            <Option type="bool" name="calendar_popup" value="true"/>
            <Option type="QString" name="display_format" value="dd-MM-yyyy HH:mm:ss"/>
            <Option type="QString" name="field_format" value="dd-MM-yyyy HH:mm:ss"/>
            <Option type="bool" name="field_iso_format" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="updating_person" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="reason_for_update" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="lineage" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" name="IsMultiline" value="false"/>
            <Option type="bool" name="UseHtml" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="class" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" name="IsMultiline" value="false"/>
            <Option type="bool" name="UseHtml" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="class_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="function" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" name="IsMultiline" value="false"/>
            <Option type="bool" name="UseHtml" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="function_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="usage" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" name="IsMultiline" value="false"/>
            <Option type="bool" name="UseHtml" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="usage_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" name="IsMultiline" value="false"/>
            <Option type="bool" name="UseHtml" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="year_of_construction" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option type="bool" name="allow_null" value="true"/>
            <Option type="bool" name="calendar_popup" value="true"/>
            <Option type="QString" name="display_format" value="yyyy"/>
            <Option type="QString" name="field_format" value="yyyy"/>
            <Option type="bool" name="field_iso_format" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="year_of_demolition" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option type="bool" name="allow_null" value="true"/>
            <Option type="bool" name="calendar_popup" value="true"/>
            <Option type="QString" name="display_format" value="yyyy"/>
            <Option type="QString" name="field_format" value="yyyy"/>
            <Option type="bool" name="field_iso_format" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="roof_type" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" name="IsMultiline" value="false"/>
            <Option type="bool" name="UseHtml" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="roof_type_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="measured_height" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" name="IsMultiline" value="false"/>
            <Option type="bool" name="UseHtml" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="measured_height_unit" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="storeys_above_ground" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="storeys_below_ground" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="storey_heights_above_ground" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option type="bool" name="IsMultiline" value="false"/>
            <Option type="bool" name="UseHtml" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="storey_heights_ag_unit" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="storey_heights_below_ground" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
    <field name="storey_heights_bg_unit" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option/>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias index="0" name="Database ID" field="id"/>
    <alias index="1" name="GML ID" field="gmlid"/>
    <alias index="2" name="GML codespace" field="gmlid_codespace"/>
    <alias index="3" name="Name" field="name"/>
    <alias index="4" name="Name codespace" field="name_codespace"/>
    <alias index="5" name="Description" field="description"/>
    <alias index="6" name="Creation date" field="creation_date"/>
    <alias index="7" name="Termination date" field="termination_date"/>
    <alias index="8" name="Relative to terrain" field="relative_to_terrain"/>
    <alias index="9" name="Relative to water" field="relative_to_water"/>
    <alias index="10" name="Last modification" field="last_modification_date"/>
    <alias index="11" name="Updating person" field="updating_person"/>
    <alias index="12" name="Reason for update" field="reason_for_update"/>
    <alias index="13" name="Lineage" field="lineage"/>
    <alias index="14" name="Class" field="class"/>
    <alias index="15" name="Codespace" field="class_codespace"/>
    <alias index="16" name="Function" field="function"/>
    <alias index="17" name="Codespace" field="function_codespace"/>
    <alias index="18" name="Usage" field="usage"/>
    <alias index="19" name="Codespace" field="usage_codespace"/>
    <alias index="20" name="Year of construction" field="year_of_construction"/>
    <alias index="21" name="Year of demolition" field="year_of_demolition"/>
    <alias index="22" name="Roof type" field="roof_type"/>
    <alias index="23" name="Codespace" field="roof_type_codespace"/>
    <alias index="24" name="Height" field="measured_height"/>
    <alias index="25" name="UoM" field="measured_height_unit"/>
    <alias index="26" name="Storeys above ground" field="storeys_above_ground"/>
    <alias index="27" name="Storeys below ground" field="storeys_below_ground"/>
    <alias index="28" name="Storey height above ground" field="storey_heights_above_ground"/>
    <alias index="29" name="UoM" field="storey_heights_ag_unit"/>
    <alias index="30" name="Storey height below ground" field="storey_heights_below_ground"/>
    <alias index="31" name="UoM" field="storey_heights_bg_unit"/>
  </aliases>
  <defaults></defaults>
  <constraints>
    <constraint unique_strength="1" exp_strength="0" constraints="3" field="id" notnull_strength="1"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="gmlid" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="gmlid_codespace" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="name" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="name_codespace" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="description" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="creation_date" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="termination_date" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="relative_to_terrain" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="relative_to_water" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="last_modification_date" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="updating_person" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="reason_for_update" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="lineage" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="class" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="class_codespace" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="function" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="function_codespace" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="usage" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="usage_codespace" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="year_of_construction" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="year_of_demolition" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="roof_type" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="0" constraints="0" field="roof_type_codespace" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="1" constraints="4" field="measured_height" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="1" constraints="4" field="measured_height_unit" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="1" constraints="4" field="storeys_above_ground" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="1" constraints="4" field="storeys_below_ground" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="1" constraints="4" field="storey_heights_above_ground" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="1" constraints="4" field="storey_heights_ag_unit" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="1" constraints="4" field="storey_heights_below_ground" notnull_strength="0"/>
    <constraint unique_strength="0" exp_strength="1" constraints="4" field="storey_heights_bg_unit" notnull_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint field="id" desc="" exp=""/>
    <constraint field="gmlid" desc="" exp=""/>
    <constraint field="gmlid_codespace" desc="" exp=""/>
    <constraint field="name" desc="" exp=""/>
    <constraint field="name_codespace" desc="" exp=""/>
    <constraint field="description" desc="" exp=""/>
    <constraint field="creation_date" desc="" exp=""/>
    <constraint field="termination_date" desc="" exp=""/>
    <constraint field="relative_to_terrain" desc="" exp=""/>
    <constraint field="relative_to_water" desc="" exp=""/>
    <constraint field="last_modification_date" desc="" exp=""/>
    <constraint field="updating_person" desc="" exp=""/>
    <constraint field="reason_for_update" desc="" exp=""/>
    <constraint field="lineage" desc="" exp=""/>
    <constraint field="class" desc="" exp=""/>
    <constraint field="class_codespace" desc="" exp=""/>
    <constraint field="function" desc="" exp=""/>
    <constraint field="function_codespace" desc="" exp=""/>
    <constraint field="usage" desc="" exp=""/>
    <constraint field="usage_codespace" desc="" exp=""/>
    <constraint field="year_of_construction" desc="" exp=""/>
    <constraint field="year_of_demolition" desc="" exp=""/>
    <constraint field="roof_type" desc="" exp=""/>
    <constraint field="roof_type_codespace" desc="" exp=""/>
    <constraint field="measured_height" desc="BOTH values must be either NULL or not NULL" exp="(&quot;measured_height&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;measured_height_unit&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;measured_height&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;measured_height_unit&quot; IS NULL)"/>
    <constraint field="measured_height_unit" desc="BOTH values must be either NULL or not NULL" exp="(&quot;measured_height&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;measured_height_unit&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;measured_height&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;measured_height_unit&quot; IS NULL)"/>
    <constraint field="storeys_above_ground" desc="Number must be >= 0" exp="(&quot;storeys_above_ground&quot; IS NULL) OR&#xd;&#xa;(&quot;storeys_above_ground&quot; >= 0)"/>
    <constraint field="storeys_below_ground" desc="Number must be >= 0" exp="(&quot;storeys_below_ground&quot; IS NULL) OR&#xd;&#xa;(&quot;storeys_below_ground&quot; >= 0)"/>
    <constraint field="storey_heights_above_ground" desc="BOTH values must be either NULL or not NULL" exp="(&quot;storey_heights_above_ground&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa; &quot;storey_heights_ag_unit&quot;  IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;storey_heights_above_ground&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;storey_heights_ag_unit&quot; IS NULL)"/>
    <constraint field="storey_heights_ag_unit" desc="BOTH values must be either NULL or not NULL" exp="(&quot;storey_heights_above_ground&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa; &quot;storey_heights_ag_unit&quot;  IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;storey_heights_above_ground&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;storey_heights_ag_unit&quot; IS NULL)"/>
    <constraint field="storey_heights_below_ground" desc="BOTH values must be either NULL or not NULL" exp="(&quot;storey_heights_below_ground&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa; &quot;storey_heights_bg_unit&quot;  IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;storey_heights_below_ground&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;storey_heights_bg_unit&quot; IS NULL)"/>
    <constraint field="storey_heights_bg_unit" desc="BOTH values must be either NULL or not NULL" exp="(&quot;storey_heights_below_ground&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa; &quot;storey_heights_bg_unit&quot;  IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;storey_heights_below_ground&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;storey_heights_bg_unit&quot; IS NULL)"/>
  </constraintExpressions>
  <expressionfields/>
  <!-- <editform tolerant="1">C:/Users/gagugiaro/AppData/Roaming/QGIS/QGIS3/profiles/default/python/plugins/3dcitydb-tools_dev/cdb4/qml/ui_form/bdg_form.ui</editform> -->
  <editform tolerant="1">_full_path_to_ui_file.ui_</editform>
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
  <editorlayout>uifilelayout</editorlayout>
  <editable>
    <field name="" editable="0"/>
    <field name="class" editable="1"/>
    <field name="class_codespace" editable="0"/>
    <field name="creation_date" editable="0"/>
    <field name="description" editable="1"/>
    <field name="function" editable="1"/>
    <field name="function_codespace" editable="0"/>
    <field name="gmlid" editable="0"/>
    <field name="gmlid_codespace" editable="0"/>
    <field name="id" editable="0"/>
    <field name="last_modification_date" editable="0"/>
    <field name="lineage" editable="0"/>
    <field name="measured_height" editable="1"/>
    <field name="measured_height_unit" editable="1"/>
    <field name="name" editable="1"/>
    <field name="name_codespace" editable="0"/>
    <field name="reason_for_update" editable="1"/>
    <field name="relative_to_terrain" editable="1"/>
    <field name="relative_to_water" editable="1"/>
    <field name="roof_type" editable="1"/>
    <field name="roof_type_codespace" editable="0"/>
    <field name="storey_heights_above_ground" editable="1"/>
    <field name="storey_heights_ag_unit" editable="1"/>
    <field name="storey_heights_below_ground" editable="1"/>
    <field name="storey_heights_bg_unit" editable="1"/>
    <field name="storeys_above_ground" editable="1"/>
    <field name="storeys_below_ground" editable="1"/>
    <field name="termination_date" editable="0"/>
    <field name="updating_person" editable="0"/>
    <field name="usage" editable="1"/>
    <field name="usage_codespace" editable="0"/>
    <field name="year_of_construction" editable="1"/>
    <field name="year_of_demolition" editable="1"/>
  </editable>
  <labelOnTop></labelOnTop>
  <reuseLastValue></reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
</qgis>
